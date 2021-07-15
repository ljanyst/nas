
#include <gflags/gflags.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <iostream>
#include <malloc.h>
#include <cstdlib>
#include <memory>
#include <cerrno>
#include <cstring>
#include <unistd.h>
#include <string>
#include <thread>
#include <chrono>
#include <vector>

DEFINE_uint64(block_size, 1048576, "block size in bytes");
DEFINE_uint64(num_buffers, 64, "number of random buffers");
DEFINE_uint64(size, 128ULL * 1024 * 1024 * 1024, "number of bytes to process");
DEFINE_bool(random, false, "should the blocks be accessed at random");
DEFINE_bool(write, true, "should the data blocks be written to the device (as opposed to being read)");
DEFINE_bool(sync, false, "issue a sync after each write");

struct FreeDelete
{
  void operator()(void* mem) {
    free(mem);
  }
};

class Monitor {
private:
  std::chrono::steady_clock::time_point begin;
  std::chrono::steady_clock::time_point end;
  std::vector<std::chrono::steady_clock::time_point> lastTime;
  std::vector<size_t> lastData;
  std::vector<std::string> dev;
  size_t step = 128 * 1024 * 1024 / FLAGS_block_size * FLAGS_block_size;
public:
  Monitor(size_t numThreads) {
    lastTime.resize(numThreads);
    lastData.resize(numThreads);
    dev.resize(numThreads);
  }

  void Begin() {
    begin = std::chrono::steady_clock::now();
  }

  void End() {
    end =  std::chrono::steady_clock::now();
  }

  void Init(size_t i, const std::string device) {
    lastTime[i] = std::chrono::steady_clock::now();
    lastData[i] = 0;
    dev[i] = device;
  }

  void Step(size_t i, size_t data) {
    if (data % step == 0) {
      std::chrono::steady_clock::time_point now = std::chrono::steady_clock::now();
      size_t procMB = (data - lastData[i]) / 1024 / 1024;
      auto time = std::chrono::duration_cast<std::chrono::milliseconds>(now - lastTime[i]).count();
      size_t dataMB = data / 1024 / 1024;
      std::cerr << "[i] " << dev[i] << ": " << dataMB << " MB @ ";
      std::cerr << (double)procMB / time * 1000.0 << " MB/s" << std::endl;
      lastTime[i] = now;
      lastData[i] = data;
    }
  }

  void PrintStats() {
    size_t totalData = 0;
    for (auto d: lastData) {
      totalData += d;
    }
    auto time = std::chrono::duration_cast<std::chrono::milliseconds>(end - begin).count();
    totalData /= 1024 * 1024;
    double speed = totalData;
    speed /= double(time) / 1000 ;
    std::cout << "[i] Total data: " << totalData << " MB" << std::endl;
    std::cout << "[i] Total time: " << time / 1000. << " s" << std::endl;
    std::cout << "[i] Total speed: " << speed << " MB/s" << std::endl;
  }
};

class DevHandler {
protected:
  Monitor *mon = nullptr;
  std::string dev = "";
  int fd = -1;
  int status = 0;
  char *buffers = nullptr;
  size_t ind = 0;

public:
  DevHandler(const std::string &dev, Monitor *mon, char *buffers, size_t ind):
    mon(mon), dev(dev), buffers(buffers), ind(ind) {}
  virtual ~DevHandler() {}

  int Open() {
    this->dev = dev;
    fd = open(dev.c_str(), O_RDWR);
    if (fd < 0) {
      std::cerr << "[!] Unable to open " << dev << ": " << strerror(errno);
      std::cerr << std::endl;
      return -1;
    }
    std::cerr << "[i] Opened " << dev << std::endl;
    return 0;
  }

  int Close() {
    if (close(fd) < 0) {
      std::cerr << "[!] Unable to close " << dev << ": " << strerror(errno);
      std::cerr << std::endl;
      return -1;
    }
    std::cerr << "[i] Closed " << dev << std::endl;
    return 0;
  }

  virtual void Run() = 0;

  int RunStatus() const {
     return status;
  }
};

class Writer: public DevHandler {
public:
  using DevHandler::DevHandler;
  virtual void Run() override {
    std::cerr << "[i] Running a writer for " << dev << std::endl;
    size_t numBlocks = FLAGS_size / FLAGS_block_size;
    mon->Init(ind, dev);
    for(size_t i = 0; i < numBlocks; ++i) {
      int blockOffset = (random() % FLAGS_num_buffers) * FLAGS_block_size;

      off_t offset = 0;
      if (FLAGS_random) {
        offset = (random() % numBlocks) * FLAGS_block_size;
      } else {
        offset = i * FLAGS_block_size;
      }
      int wr = pwrite(fd, buffers + blockOffset, FLAGS_block_size, offset);
      if (wr != FLAGS_block_size) {
        std::cerr << "[!] Unable to write to " << dev << ": " << strerror(errno);
        std::cerr << std::endl;
        status = -1;
        return;
      }
      if (FLAGS_sync) {
        fsync(fd);
      }

      mon->Step(ind, (i+1) * FLAGS_block_size);
    }
    status = 0;
  }
};

class SeqReader: public DevHandler {
public:
  using DevHandler::DevHandler;
  virtual void Run() override {
    std::cerr << "[!] Running a reader for " << dev << std::endl;
    size_t numBlocks = FLAGS_size / FLAGS_block_size;
    char *buffer = (char *)malloc(FLAGS_block_size);
    mon->Init(ind, dev);
    for(size_t i = 0; i < numBlocks; ++i) {
      int rd = read(fd, buffer, FLAGS_block_size);
      if (rd != FLAGS_block_size) {
        std::cerr << "[!] Unable to read from " << dev << ": " << strerror(errno);
        std::cerr << std::endl;
        status = -1;
        free(buffer);
        return;
      }
      mon->Step(ind, (i+1) * FLAGS_block_size);
    }
    status = 0;
    free(buffer);
  }
};

class Reader: public DevHandler {
public:
  using DevHandler::DevHandler;
  virtual void Run() override {
    std::cerr << "[i] Running a random reader for " << dev << std::endl;
    size_t numBlocks = FLAGS_size / FLAGS_block_size;
    char *buffer = (char *)malloc(FLAGS_block_size);
    mon->Init(ind, dev);
    for(size_t i = 0; i < numBlocks; ++i) {
      off_t offset = 0;
      if (FLAGS_random) {
        offset = (random() % numBlocks) * FLAGS_block_size;
      } else {
        offset = i * FLAGS_block_size;
      }
      int rd = pread(fd, buffer, FLAGS_block_size, offset);
      if (rd != FLAGS_block_size) {
        std::cerr << "[!] Unable to read from " << dev << ": " << strerror(errno);
        std::cerr << std::endl;
        status = -1;
        free(buffer);
        return;
      }
      mon->Step(ind, (i+1) * FLAGS_block_size);
    }
    status = 0;
    free(buffer);
  }
};

int loadRandom(char *buffers, size_t buffersSize) {
  int fd = open("/dev/urandom", O_RDONLY);
  if (fd < 0) {
    std::cerr << "[!] Unable to open /dev/urandom: " << strerror(errno);
    std::cerr << std::endl;
    return -1;
  }

  while (buffersSize > 0) {
    int rd = read(fd, buffers, buffersSize);
    if (rd < 0) {
      std::cerr << "[!] Unable to read from /dev/urandom: " << strerror(errno);
      std::cerr << std::endl;
      close(fd);
      return -1;
    }
    buffersSize -= rd;
    buffers += rd;
  }

  return 0;
}

int main(int argc, char **argv) {
  gflags::SetUsageMessage("[flags] block devices");
  gflags::ParseCommandLineFlags(&argc, &argv, true);
  if (argc == 1) {
    gflags::ShowUsageWithFlags(argv[0]);
    return 1;
  }

  std::cerr << "[i] Block size: " << FLAGS_block_size << std::endl;
  if (FLAGS_write) {
    std::cerr << "[i] Operation:  write" << std::endl;
  } else {
    std::cerr << "[i] Operation:  read" << std::endl;
  }
  std::cerr << "[i] Random:     " << (FLAGS_random ? "true" : "false") << std::endl;
  std::cerr << "[i] Sync:       " << (FLAGS_sync ? "true" : "false") << std::endl;

  size_t buffersSize = FLAGS_block_size * FLAGS_num_buffers;
  char *buffers = (char*)memalign(0x1000, buffersSize);
  std::unique_ptr<char, FreeDelete> buffersGuard(buffers);
  if (!buffers) {
    std::cerr << "[!] Unable to allocate the buffers" << std::endl;
    return 1;
  }

  if (loadRandom(buffers, buffersSize) != 0) {
    std::cerr << "[!] Cannot load random data into buffers" << std::endl;
    return 1;
  }
  std::cerr << "[i] Random data loaded" << std::endl;

  std::vector<std::unique_ptr<DevHandler>> handlers;
  std::vector<std::thread> threads;
  Monitor monitor = Monitor(argc - 1);
  for (int i = 1; i < argc; ++i) {
    if (FLAGS_write) {
      handlers.emplace_back(new Writer(argv[i], &monitor, buffers, i - 1));
    } else {
      handlers.emplace_back(new Reader(argv[i], &monitor, buffers, i - 1));
    }
    if (handlers[i-1]->Open() != 0) {
      return 1;
    }
  }

  monitor.Begin();
  for (int i = 0; i < argc - 1; ++i) {
    threads.emplace_back([&handlers, i]() { handlers[i]->Run(); });
  }

  bool success = true;
  for (int i = 0; i < argc - 1; ++i) {
    threads[i].join();
    if (handlers[i]->RunStatus() != 0) {
      success = false;
    }

    if (handlers[i]->Close() != 0) {
      success = false;
    }
  }
  monitor.End();

  if (!success) {
    std::cerr << "[!] Some threads failed" << std::endl;
    return 1;
  }

  monitor.PrintStats();

  return 0;
}
