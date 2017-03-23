#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerPull: 'quay.io/biocontainers/idr:2.0.3--py35_4'

baseCommand: ["idr"]

inputs:
  samples:
    type: File[]
    inputBinding:
      prefix: --samples
      position: 1
  peak-list:
    type: File?
    inputBinding:
      prefix: --peak-list
      position: 2

outputs:
  log:
    type: stdout
  output:
    type: File
    outputBinding:
        glob: idrValues.txt
    
