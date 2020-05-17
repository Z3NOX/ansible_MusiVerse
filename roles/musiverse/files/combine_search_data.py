#!/usr/bin/env python3
import json
import argparse

p = argparse.ArgumentParser()
p.add_argument("--input", "-i", nargs="+", required=True, type=argparse.FileType('r'),
               help="input files normally called ’search-data.json’ originating from "
                    "different jekyll runs")
p.add_argument("--output", "-o", type=argparse.FileType('w'), default="search-data.json")

args = p.parse_args()

gather_dict = {}
maxentries = 0
for inputfile in args.input:
    with inputfile as file:
        searchdata = json.load(file)
    for key in searchdata:
        gather_dict[maxentries + int(key)] = searchdata[key]

    maxentries = max([int(x) for x in gather_dict.keys()])


with args.output as file:
    json.dump(gather_dict, file)
