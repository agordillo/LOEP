class Metadata::Dc < Metadata

  class << self

    def compliant?(xmlDoc)
      false #not implemented yet
    end

    def getContent(xmlDoc)
      nil
    end

    def schema
      "Dublin Core"
    end

    def metadata_json(metadataRecord)
      {}
    end

    def metadata_fields(metadataRecord)
      {}
    end

    def metadata_xml(metadataRecord)
      Metadata.getEmptyXml
    end

  end

end