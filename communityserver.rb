require File.expand_path(File.dirname(__FILE__) + '/base.rb')

require 'csv'

class ImportScripts::CommunityServer < ImportScripts::Base
  def initialize
    super
  end

  def execute
    users = CSV.read('tdwtf-users.csv', headers: true)
    create_users(users) do |u|
      ActiveSupport::HashWithIndifferentAccess.new u.to_hash
    end

    # begin specific to TDWTF
    {'18' => 10, '16' => 13, '17' => 17, '19' => 14, '21' => 4}.each do |cs, dc|
      c = Category.find(dc)
      c.custom_fields['import_id'] = cs
      c.save!
      @categories[cs] = c
    end
    # end specific to TDWTF

    categories = CSV.read('tdwtf-categories.csv', headers: true)
    create_categories(categories) do |c|
      ActiveSupport::HashWithIndifferentAccess.new c.to_hash
    end
  end
end

ImportScripts::CommunityServer.new.perform
