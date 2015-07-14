module LosHelper
	def rlo_path(lo)
		return "/rlos/" + lo.id.to_s
	end

	def download_path(los,format)
		return "/los/download." + format + "?lo_ids="+getLoIds(los)
	end

	def download_evs_path(los,format)
		return "/los/downloadevs." + format + "?lo_ids="+getLoIds(los)
	end

	def show_metadata_path(lo)
		return LOEP::Application.config.full_domain + "/los/" + lo.id.to_s + "/metadata.xml"
	end


	private

	def getLoIds(los)
		if los.is_a? ActiveRecord::Relation
			los = los.all
		end

		if !los.is_a? Array
			los = [los]
		end

		lo_ids = nil
		los.each do |lo|
			if lo_ids.nil?
				lo_ids = lo.id.to_s
			else
				lo_ids = lo_ids + "," + lo.id.to_s
			end
		end
		lo_ids
	end

end