package main

import (
	"encoding/csv"
	"fmt"
	"image/color"
	"io"
	"io/ioutil"
	"log"
	"os"
	"strconv"

	"golang.org/x/image/font/opentype"
	"gonum.org/v1/plot"
	"gonum.org/v1/plot/font"
	"gonum.org/v1/plot/plotter"
	"gonum.org/v1/plot/plotutil"
	"gonum.org/v1/plot/vg"
)

func makeBarChart(vals plotter.Values, color color.Color, width, offset vg.Length) *plotter.BarChart {
	chart, err := plotter.NewBarChart(vals, width)
	if err != nil {
		panic(err)
	}
	chart.LineStyle.Width = vg.Length(0)
	chart.Color = color
	chart.Offset = offset
	return chart
}

func strToFloat(str string) float64 {
	if s, err := strconv.ParseFloat(str, 64); err != nil {
		log.Fatal(err)
	} else {
		return s
	}
	return 0
}

type Chart struct {
	Name   string
	Values plotter.Values
	Chart  *plotter.BarChart
}

func main() {
	if len(os.Args) < 3 {
		fmt.Printf("Usage: %s input.csv output.png\n", os.Args[0])
		os.Exit(1)
	}

	csvfile, err := os.Open(os.Args[1])
	if err != nil {
		log.Fatalf("Can't open the csv file: %s\n", err)
	}

	r := csv.NewReader(csvfile)
	charts := []Chart{}
	header := true
	for {
		record, err := r.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Fatal(err)
		}

		if header {
			header = false
			continue
		}

		vals := plotter.Values{}
		for i := 1; i < len(record); i++ {
			vals = append(vals, strToFloat(record[i]))
		}
		charts = append(charts, Chart{
			record[0],
			vals,
			nil,
		})
	}

	ttf, err := ioutil.ReadFile("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf")
	if err != nil {
		log.Fatal(err)
	}

	fontTtf, err := opentype.Parse(ttf)
	if err != nil {
		log.Fatal(err)
	}

	dejaVu := font.Font{
		Typeface: "DejaVu",
		Variant:  "Sans",
	}
	font.DefaultCache.Add([]font.Face{
		font.Face{
			Font: dejaVu,
			Face: fontTtf,
		},
	})
	plot.DefaultFont = dejaVu
	plotter.DefaultFont = dejaVu

	p := plot.New()
	p.Y.Label.Text = "MB/s"
	p.BackgroundColor = color.RGBA{0xd9, 0xe7, 0xd9, 0xff}
	p.X.Color = color.RGBA{0xd9, 0xe7, 0xd9, 0xff}
	p.X.Tick.Color = color.RGBA{0xd9, 0xe7, 0xd9, 0xff}

	w := vg.Points(15)
	for i, v := range charts {
		chart := makeBarChart(v.Values, plotutil.Color(i), w, font.Length(i)*w)
		p.Add(chart)
		p.Legend.Add(v.Name, chart)
	}

	p.Legend.Top = true

	p.X.Tick.Marker = commaTicks{}
	p.X.Min = 0
	p.X.Max = 5.8

	if err := p.Save(450, 300, os.Args[2]); err != nil {
		panic(err)
	}
}

type commaTicks struct{}

func (commaTicks) Ticks(min, max float64) []plot.Tick {
	return []plot.Tick{
		plot.Tick{0.33, "wr-seq"},
		plot.Tick{1.33, "wr-rnd"},
		plot.Tick{2.33, "wr-seq-nc"},
		plot.Tick{3.33, "wr-rnd-nc"},
		plot.Tick{4.33, "rd-seq"},
		plot.Tick{5.33, "rd-rnd"},
	}
}
