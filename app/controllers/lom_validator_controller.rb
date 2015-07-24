class LomValidatorController < ApplicationController

  def index
    render layout: "application_without_menu"
  end

  def validate
    result = Hash.new
    result[:errors] = []

    metadata = nil
    unless params["lom_xml"].blank?
      begin
        doc = Nokogiri::XML(params["lom_xml"])
        metadata = Hash.from_xml_with_attributes(doc)
      rescue
        doc = nil
        metadata = nil
      end

      if doc.nil? or metadata.nil?
        result[:errors] << "XML file is not well-formed"
      else
        if Metadata::Lom.compliant?(doc)
          #Calculate Metadata Quality
          metadataFields = Metadata::Lom.metadata_fields_from_json(metadata["lom"]) rescue {}
          result[:quality_score] = Metrics::LomMetadata.getScoreForMetadata(metadataFields).round(1)
        else
          result[:errors] << "XML file is not LOM compliant"
        end
      end
    else
      result[:errors] << "Metadata file is empty"
    end

    if request.xhr?
      render :json => result
    else
      @result = result
      render "index", layout: "application_without_menu"
    end
  end

end
