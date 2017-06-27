#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: 'quay.io/biocontainers/ucsc-bedgraphtobigwig'
  SoftwareRequirement:
    packages:
    - package: ucsc-bedgraphtobigwig
      version: [ 332 ]

baseCommand: ["bedGraphToBigWig"]

inputs:
  input:
    type: File
    inputBinding:
      position: 1
  chrom_sizes:
    type: File
    inputBinding:
      position: 2

arguments:
  output:
    valueFrom: $(inputs.input.basename).bw
    inputBinding:
      position: 3


outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.input.basename).bw
