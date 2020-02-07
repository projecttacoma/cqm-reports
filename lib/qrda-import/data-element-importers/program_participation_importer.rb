module QRDA
  module Cat1
    class ProgramParticipationImporter < SectionImporter
      def initialize(entry_finder = QRDA::Cat1::EntryFinder.new("./cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.154']"))
        super(entry_finder)
        @id_xpath = './cda:id'
        @code_xpath = './cda:value'
        @participation_period_xpath = "./cda:effectiveTime"
        @entry_class = QDM::Participation
      end

      def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
        program_participation = super
        program_participation.participationPeriod = extract_interval(entry_element, @participation_period_xpath)
        program_participation.recorder = extract_entity(entry_element, "./cda:participant[@typeCode='PRF']")
        program_participation
      end

    end
  end
end