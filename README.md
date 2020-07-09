# cqm-reports
A library for import and export of reports for use with electronic Clinical Quality Measures (eCQMs).

Versioning
==========

Starting with version **2.0.0** released on 6/20/2019, cqm-reports versioning has the format **X.Y.Z**, where:

* **X** maps to a version of QRDA. See the table below to see the existing mapping to QRDA versions.

  | X | QRDA Cat 1 | QRDA Cat 3 |
  | --- | --- | --- |
  | 2 | R1 STU5.1 | R1 STU2.1 |

* **Y** indicates major changes (incompatible API changes)

* **Z** indicates minor changes (added functionality in a backwards-compatible manner) and patch changes (backwards-compatible bug fixes)

For the versions available, see [tags on this repository](https://github.com/projecttacoma/cqm-validators/tags).

=======
Importing QRDA
==========

A QRDA document can be imported into a CQM::Patient (defined in [cqm-models](https://github.com/projecttacoma/cqm-models)) using the following commands.

        doc = Nokogiri::XML(file)
        patient, warnings = QRDA::Cat1::PatientImporter.instance.parse_cat1(doc)

Exporting QRDA Category I
==========

Exporting a QRDA document from a CQM::Patient (defined in [cqm-models](https://github.com/projecttacoma/cqm-models)) using the following command.

        Qrda1R5.new(patient, measures, options).render
* patient is a [CQM::Patient](https://github.com/projecttacoma/cqm-models/blob/master/app/models/cqm/patient.rb)
* measures is an array of [CQM::Measure](https://github.com/projecttacoma/cqm-models/blob/master/app/models/cqm/measure.rb)
* options is a hash that can be used to pass in:
  * provider
  * patient_addresses
  * patient_telecoms
  * start_time
  * end_time
  * submission_program 

QRDA export requires the [mustache](https://github.com/mustache/mustache) gem 

## License

Copyright 2019 The MITRE Corporation

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
