#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerPull: quay.io/biocontainers/macs:2.1.1.20160309--r3.2.2_0
  - class: ResourceRequirement
    coresMax: 112

baseCommand: [ macs, callpeak, --outdir, outdir ]

inputs:
  treatment:
    type: File
    inputBinding:
      position: 2
      prefix: -t
  control:
    type: File
    inputBinding:
      position: 3
      prefix: -c
  genome_size:
    type: string
    default: 'mm'

outputs:
  narrowpeak_file:
    type: File
    outputBinding:
      glob: "outdir/*_peaks.narrowPeak"
