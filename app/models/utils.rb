# encoding: utf-8

class Utils

  def self.getOptionsForSelectLan(resource,options=nil)
    addUnespecified = false
    addLIndependent = false
    translate = (!options.nil? and !options[:current_user].nil?)

    unless resource.nil?
      if resource.class.name == "User"
        addUnespecified = (resource.language.nil? and (options.nil? or options[:multiple]!=true))
      elsif resource.class.name == "Lo"
        addUnespecified = resource.language.nil?
        addLIndependent = true
      end
    end

    #Special languages
    lOther = Language.find_by_code("lanot")
    lIndependent = Language.find_by_code("lanin")

    #Get all languages (but other)
    languages = Language.all.reject{|l| [lOther.id,lIndependent.id].include? l.id}.map{ |l| [(translate ? l.translated_name : l.name),l.id] }.sort_by{ |l| l[0].downcase }

    if addLIndependent
      languages = languages.push([lIndependent.translated_name,lIndependent.id])
      languages = languages.sort{ |a,b|
        if a[1]==lIndependent.id
          -1
        elsif b[1]==lIndependent.id
          +1
        else
         0
        end
      }
    end

    if addUnespecified
      languages.unshift([I18n.t("dictionary.unspecified"),-1])
    end

    #Add other at the end
    languages.push([lOther.translated_name,lOther.id])

    languages
  end

  def self.getEvMethods
    Evmethod.allc.map { |evmethod| [evmethod.name,evmethod.id] }
  end

  def self.getOptionsForSelectAssignmentStatus
    [[I18n.t("assignments.status.pending"),"Pending"],[I18n.t("assignments.status.completed"),"Completed"],[I18n.t("assignments.status.rejected"),"Rejected"]]
  end

  def self.getOptionsForSelectLOScope
    [[I18n.t("scopes.private"),"Private"],[I18n.t("scopes.protected"),"Protected"],[I18n.t("scopes.public"),"Public"]]
  end

  def self.getOptionsForOccupation
    I18n.t("occupations").map{|k,v| [v,k.to_s]}
  end

  def self.getOptionsForSelectLOContextContext
    I18n.t("context.lo.context_select").map{|k,v| [v,k.to_s]}
  end

  def self.getOptionsForSelectLOContextStrategy
    I18n.t("context.lo.strategy_select").map{|k,v| [v,k.to_s]}
  end

  def self.getOptionsForSelectRoles(current_user)
    roles = []
    if current_user.isAdmin?
      roles = Role.all.reject{|r| r.value >= current_user.value}.map{|r| r}
      if LOEP::Application.config.register_policy=="FREE"
        roles = (roles & [Role.default])
      end
    end
    roles.map{|r| [r.readable,r.id] }
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
    queries.uniq!
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

  def self.build_token(model,length=60,field_name="auth_token")
    begin
      token = SecureRandom.urlsafe_base64(length)
    end while (model.exists?(field_name => token))
    token
  end

  def self.parseLinks(s)
    #regexp
    url = /( |[(.]|^)(http[s]?:\/\/[^\s&^)]+)( |[).]|$)/

    #replace urls with links
    iLinks = 0
    while s =~ url
      iLinks += 1
      if iLinks > 50
        return s
      end
      sStart = $1
      urlValue = $2
      sEnding = $3
      s.sub! /( |[(.]|^)#{urlValue.gsub("?","\\?").gsub("/","\\\/")}( |[).]|$)/, "#{sStart}<a href='#{urlValue}' target='_blank'>#{urlValue}</a>#{sEnding}"
    end

     return s
  end

end