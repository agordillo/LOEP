# encoding: utf-8

class Api::V1::BaseController < ApplicationController

  #################
  # Authentication for Web Apps
  ################

  before_filter :authenticate_app!

end