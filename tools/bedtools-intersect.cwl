#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: 'quay.io/biocontainers/bedtools:2.26.0gx--0'
  SoftwareRequirement:
    packages:
    - package: bedtools
      version: [ 2.26.0gx ]

baseCommand: ["bedtools", "intersect"]

inputs:
  a:
    type: File
    inputBinding:
      prefix: -a
      position: 2
  b:
    type: File
    inputBinding:
      prefix: -b
      position: 3
  v:
    type: boolean
    default: false
    inputBinding:
      prefix: -v

outputs:
  output:
    type: stdout
    format: bed
