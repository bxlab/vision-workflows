#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerPull: quay.io/biocontainers/macs2:2.1.1.20160309--r3.2.2_0
  - class: ResourceRequirement
    coresMax: 112

baseCommand: [ macs2, bdgcmp ]

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
  method:
    type: string
    inputBinding:
      position: 1
      prefix: -m

arguments:
- prefix: "-o"
  valueFrom: $(inputs.treatment.basename).bdg
  inputBinding:
    position: 4

outputs:
  bdg:
    type: File
    outputBinding:
      glob: "outdir/*_peaks.narrowPeak"
