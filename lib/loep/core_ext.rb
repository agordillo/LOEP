Hash.class_eval do
  class << self
    def from_xml_with_attributes(xml)
      begin
        if xml.is_a? String
          from_xml_with_attributes_string(xml)
        elsif xml.is_a? Nokogiri::XML::Element or xml.is_a? Nokogiri::XML::Document
          from_xml_with_attributes_nokogiri(xml)
        else
          Hash.new
        end
      rescue
        Hash.new
      end
    end

    def from_xml_with_attributes_string(xml_str)
      from_xml_with_attributes_nokogiri(Nokogiri::XML(xml_str))
    end

    def from_xml_with_attributes_nokogiri(xmlNokogiri)
      if xmlNokogiri.is_a? Nokogiri::XML::Document
        return { xmlNokogiri.root.name => xml_node_to_hash(xmlNokogiri.root)}
      elsif xmlNokogiri.is_a? Nokogiri::XML::Element
        return { xmlNokogiri.name => xml_node_to_hash(xmlNokogiri)}
      end
    end

    def xml_node_to_hash(node)
      # If we are at the root of the document, start the hash 
      if node.element?
        result_hash = {}

        attributes = {}
        unless node.attributes.blank?
          node.attributes.keys.each do |key|
            attributes[node.attributes[key].name] = node.attributes[key].value
          end
        end

        node.children.each do |child|
          result = xml_node_to_hash(child)

          if child.name == "text"
            unless child.next_sibling || child.previous_sibling
              result_hash["value"] = result
            end
          elsif result_hash[child.name]
            if result_hash[child.name].is_a?(Object::Array)
               result_hash[child.name] << result
            else
               result_hash[child.name] = [result_hash[child.name]] << result
            end
          else
            result_hash[child.name] = result
          end
        end
        unless attributes.blank?
          #add code to remove non-data attributes e.g. xml schema, namespace here
          result_hash["@attributes"] = attributes
        end
        result_hash["@line"] = node.line if node.line
        return result_hash
      else
        return node.content.to_s
      end
    end
  end
end