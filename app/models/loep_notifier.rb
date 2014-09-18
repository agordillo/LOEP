# encoding: utf-8
require 'restclient'
require 'json'
require 'base64'

class LoepNotifier

  # Notify an app that a LO has new information available
  # Request example
  # PUT http://localhost:3000/loep/los/Excursion:55
  # Use HTTP Basic Authentication (App Name and App Auth Token are sent in the Authorization header)
  def self.notifyLoUpdate(app,lo)
    if app.callback.blank? or app.auth_token.blank? or lo.id_repository.blank?
      return
    end

    basePath = app.callback
    if app.callback.last != "/"
      basePath = app.callback + "/"
    end
    fullPath = basePath + "los/" + lo.id_repository.to_s

    #Build params
    params = Hash.new
    params["id_loep"] = lo.id
    params["id_repository"] = lo.id_repository
    params["lo"] = lo.extended_attributes.to_json

    require 'thread'
    Thread.new {
      begin
        response = RestClient::Request.execute(
          :method => :put,
          :url => fullPath,
          :payload => params,
          :headers => {:'Authorization' => getBasicAuthHeader(app)}
        )
      rescue Exception => e
        # puts e.message
      end
    }
    end

  private

  def self.getBasicAuthHeader(app)
    'Basic ' + Base64.encode64(app.name + ":" + app.auth_token).gsub("\n","")
  end

end
