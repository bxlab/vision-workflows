#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/bwa:0.7.15--0
  SoftwareRequirement:
    packages:
    - package: bwa
      version: [ 0.7.15 ]
  ResourceRequirement:
    coresMax: 112

baseCommand: [ bwa, mem ]

arguments:
- prefix: "-t"
  valueFrom: $(runtime.cores)

inputs:
  idxbase:
    type: File
    secondaryFiles: [ .amb, .ann, .bwt, .pac, .sa ]
    inputBinding:
      position: 2
  reads:
    type:
      type: record
      fields:
        in1:
          type: File
          inputBinding:
            position: 3
        in2:
          type: File?
          inputBinding:
            position: 4

outputs:
  output:
    type: stdout
    format: bam
