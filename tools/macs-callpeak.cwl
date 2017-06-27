#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/macs2:2.1.1.20160309--r3.2.2_0
  SoftwareRequirement:
    packages:
    - package: macs2
      version: [ 2.1.1.20160309 ]
  ResourceRequirement:
    coresMax: 112

baseCommand: [ macs2, callpeak, -B, --outdir, outdir ]

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
  treatment_pileup_bdg:
    type: File
    outputBinding:
      glob: "outdir/*_treat_pileup.bdg"
  control_lambda_bdg:
    type: File
    outputBinding:
      glob: "outdir/*_control_lambda.bdg"
