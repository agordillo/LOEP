# encoding: utf-8

class Utils < ActiveRecord::Base

  #Constants

  def self.getOptionsForSelectLan(resource,options=nil)
    addUnespecified = false
    addLIndependent = false

    if !resource.nil?
      if resource.class.name == "User"
        addUnespecified = (resource.language.nil? and (options.nil? or options[:multiple]!=true))
      elsif resource.class.name == "Lo"
        addUnespecified = resource.language.nil?
        addLIndependent = true
      end
    end

    languages = Language.all.map{ |l| [l.name,l.id] }.sort_by{ |l| l[0].downcase }

    lIndependentId = Language.find_by_shortname("lanin").id
    if !addLIndependent
      languages = languages.reject{|l| l[1]==lIndependentId}
    else
      languages = languages.sort{ |a,b|
        if a[1]==lIndependentId
          1
        elsif b[1]==lIndependentId
          -1
        else
         0
        end
      }
    end

    if addUnespecified
      languages.unshift(["Unspecified",-1])
    end

    languages
  end

  def self.getEvMethods
    Evmethod.all.map { |evmethod| [evmethod.name,evmethod.id] }
  end

  def self.getOptionsForSelectAssignmentStatus
    [["Pending","Pending"],["Completed","Completed"],["Rejected","Rejected"]]
  end

  def self.getOptionsForSelectLOScope
    [["Private","Private"],["Protected","Protected"],["Public","Public"]]
  end

  def self.getOptionsForOccupation
    [["Education (teacher, pedagogue, ...)","Education"],["Technology (educational content developer, IT support, ...)","Technology"],["Other","Other"]]
  end


  #Dates

  def self.getReadableDate(date)
    unless date.nil?
      date.strftime("%d/%m/%Y %H:%M %P")
      #For Ruby < 1.9
      # date.strftime("%d/%m/%Y %H:%M %p").sub(' AM', ' am').sub(' PM', ' pm')
    else
      ""
    end
  end


  #Session redirects

  def self.update_return_to(session,request)
    session[:return_to] ||= request.referer
  end

  def self.update_sessions_paths(session, afterDestroy, afterDestroyDependence)
    session.delete(:return_to)
    if !afterDestroy.nil?
      session[:return_to_afterDestroy] = afterDestroy
    else
      session.delete(:return_to_afterDestroy)
    end
    if !afterDestroyDependence.nil?
      session[:return_to_afterDestroyDependence] = afterDestroyDependence
    else
      session.delete(:return_to_afterDestroyDependence)
    end
  end

  def self.return_after_create_or_update(session)
    if session[:return_to]
      session.delete(:return_to)
    else
      Rails.application.routes.url_helpers.home_path
    end
  end

  def self.return_after_destroy_path(session)
    if session[:return_to_afterDestroyDependence]
      session.delete(:return_to_afterDestroy)
      return session.delete(:return_to_afterDestroyDependence)
    elsif session[:return_to_afterDestroy]
      session.delete(:return_to_afterDestroyDependence)
      return session.delete(:return_to_afterDestroy)
    else
      Rails.application.routes.url_helpers.home_path
    end
  end

  #Querys
  def self.composeQuery(queries)
    composedQuery = nil
    queries.each_with_index do |query,index|
      if index!=0
        composedQuery = composedQuery + " and " + query
      else
        composedQuery = query
      end
    end
    composedQuery
  end

  #More Utils

  def self.is_numeric?(str)
    true if Float(str) rescue false
  end

  def self.build_token(length=60)
    begin
      token = SecureRandom.urlsafe_base64(length)
    end while App.exists?(auth_token: token)
    token
  end

end