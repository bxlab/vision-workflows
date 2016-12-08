#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement

inputs:
  reads:
    doc: Reads to map, either single or paired
    type:
      type: array
      items:
          type: record
          fields:
            in1: File
            in2: File?
  idxbase:
    doc: Base filename of bwa index to map against
    type: File
  blacklist:
    doc: Blacklist regions to remove
    type: File

outputs:
  processed_reads:
    type: File[]
    outputSource: remove_blacklist/output

steps:
  align:
    run: ./tools/bwa-mem.cwl
    in:
      reads: reads
      idxbase: idxbase
    out: [output]
    scatter: [ reads ]
    scatterMethod: dotproduct
  to_bam:
    run: ./tools/samtools-samtobam.cwl
    in:
      input: align/output
    out: [output]
    scatter: [ input ]
  sort:
    run: ./tools/samtools-sort.cwl
    in:
      input: to_bam/output
    out: [output]
    scatter: [ input ]
  mark_duplicates:
    run: ./tools/picard-MarkDuplicates.cwl
    in:
      input: sort/output
    out: [output]
    scatter: [ input ]
  remove_unmapped:
    run: ./tools/samtools-view.cwl
    in:
      input: mark_duplicates/output
      filter_none_set:
        valueFrom: "4"
    out: [output]
    scatter: [ input ]
  remove_blacklist:
    run: ./tools/bedtools-intersect.cwl
    in:
      a: remove_unmapped/output
      b: blacklist
      v:
        valueFrom: ${ return true; }
    out: [output]
    scatter: [ a ]
