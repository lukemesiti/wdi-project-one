class PagesController < ApplicationController
    skip_before_action :authenticate
  def about_us
  end

  def contact_us
  end

  def home
  end
end
