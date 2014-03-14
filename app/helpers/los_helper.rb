module LosHelper
	def rlo_path(lo)
		return "/rlos/" + lo.id.to_s
	end

	def download_path(los,format)
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

		return "/los/download." + format + "?lo_ids="+lo_ids
	end
end