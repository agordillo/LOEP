Hash.class_eval do
  class << self
    def from_xml_with_attributes(xml_str)
      begin
        result = Nokogiri::XML(xml_str)
        return { result.root.name => xml_node_to_hash(result.root)}
      rescue Exception => e
        return Hash.new
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
        if node.children.size > 0
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
             result_hash[:attributes] = attributes
          end
          return result_hash
        else
          return attributes
        end
      else
        return node.content.to_s
      end
    end
  end
end