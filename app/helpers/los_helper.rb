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
		los = los.all if los.is_a? ActiveRecord::Relation
		los = [los] unless los.is_a? Array
		los.map{|lo| lo.id.to_s}.join(",")
	end

end