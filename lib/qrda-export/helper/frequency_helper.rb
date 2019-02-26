module Qrda
  module Export
    module Helper
      module FrequencyHelper
        # FREQUENCY_CODE_MAP extracted from Direct Reference Codes in Opioid_v5_6_eCQM.xml (CMS460v0)
        FREQUENCY_CODE_MAP = {
          '229799001' => { in_hours: 12, codeSystem: '2.16.840.1.113883.6.96', codeSystemName: 'SNOMEDCT', codeSystemVersion: '2018-03', displayName: 'Twice a day (qualifier value)' },
          '307470009' => { in_hours: 12, codeSystem: '2.16.840.1.113883.6.96', codeSystemName: 'SNOMEDCT', codeSystemVersion: '2018-03', displayName: 'Every twelve hours (qualifier value)' },
          '396131002' => { in_hours: 48, codeSystem: '2.16.840.1.113883.6.96', codeSystemName: 'SNOMEDCT', codeSystemVersion: '2018-03', displayName: 'Every forty eight hours (qualifier value)' },
          '396125000' => { in_hours: 24, codeSystem: '2.16.840.1.113883.6.96', codeSystemName: 'SNOMEDCT', codeSystemVersion: '2018-03', displayName: 'Every twenty four hours (qualifier value)' },
          '396109005' => { in_hours: 6, codeSystem: '2.16.840.1.113883.6.96', codeSystemName: 'SNOMEDCT', displayName: 'One to four times a day (qualifier value)' },
          '396126004' => { in_hours: 36, codeSystem: '2.16.840.1.113883.6.96', codeSystemName: 'SNOMEDCT', codeSystemVersion: '2018-03', displayName: 'Every thirty six hours (qualifier value)' },
          '225756002' => { in_hours: 4, codeSystem: '2.16.840.1.113883.6.96', codeSystemName: 'SNOMEDCT', displayName: 'Every four hours (qualifier value)' },
          '396139000' => { in_hours: 6, codeSystem: '2.16.840.1.113883.6.96', codeSystemName: 'SNOMEDCT', displayName: 'Every six to eight hours (qualifier value)' },
          '225754004' => { in_hours: 3, codeSystem: '2.16.840.1.113883.6.96', codeSystemName: 'SNOMEDCT', displayName: 'Every three to four hours (qualifier value)' },
          '396140003' => { in_hours: 8, codeSystem: '2.16.840.1.113883.6.96', codeSystemName: 'SNOMEDCT', displayName: 'Every eight to twelve hours (qualifier value)' },
          '396107007' => { in_hours: 12, codeSystem: '2.16.840.1.113883.6.96', codeSystemName: 'SNOMEDCT', displayName: 'One to two times a day (qualifier value)' },
          '396108002' => { in_hours: 8, codeSystem: '2.16.840.1.113883.6.96', codeSystemName: 'SNOMEDCT', displayName: 'One to three times a day (qualifier value)' },
          '396111001' => { in_hours: 12, codeSystem: '2.16.840.1.113883.6.96', codeSystemName: 'SNOMEDCT', displayName: 'Two to four times a day (qualifier value)' },
          '307469008' => { in_hours: 8, codeSystem: '2.16.840.1.113883.6.96', codeSystemName: 'SNOMEDCT', codeSystemVersion: '2018-03', displayName: 'Every eight hours (qualifier value)' },
          '229797004' => { in_hours: 24, codeSystem: '2.16.840.1.113883.6.96', codeSystemName: 'SNOMEDCT', codeSystemVersion: '2018-03', displayName: 'Once daily (qualifier value)' },
          '229798009' => { in_hours: 8, codeSystem: '2.16.840.1.113883.6.96', codeSystemName: 'SNOMEDCT', codeSystemVersion: '2018-03', displayName: 'Three times daily (qualifier value)' },
          '307439001' => { in_hours: 6, codeSystem: '2.16.840.1.113883.6.96', codeSystemName: 'SNOMEDCT', codeSystemVersion: '2018-03', displayName: 'Four times daily (qualifier value)' },
          '307468000' => { in_hours: 6, codeSystem: '2.16.840.1.113883.6.96', codeSystemName: 'SNOMEDCT', codeSystemVersion: '2018-03', displayName: 'Every six hours (qualifier value)' },
          '396127008' => { in_hours: 3, codeSystem: '2.16.840.1.113883.6.96', codeSystemName: 'SNOMEDCT', displayName: 'Every three to six hours (qualifier value)' },
          '225752000' => { in_hours: 2, codeSystem: '2.16.840.1.113883.6.96', codeSystemName: 'SNOMEDCT', displayName: 'Every two to four hours (qualifier value)' },
          '396143001' => { in_hours: 72, codeSystem: '2.16.840.1.113883.6.96', codeSystemName: 'SNOMEDCT', codeSystemVersion: '2018-03', displayName: 'Every seventy two hours (qualifier value)' }
        }.freeze

        def medication_frequency
          # If the code matches one of the known Direct Reference Codes, export that time in hours. Otherwise default to 24 hours
          medication_period = FREQUENCY_CODE_MAP[self['code']]&.in_hours || 24
          "<effectiveTime xsi:type='PIVL_TS' institutionSpecified='true' operator='A'>"\
          "<period value='#{medication_period}' unit='h'/>"\
          "</effectiveTime>"
        end
      end
    end
  end
end
