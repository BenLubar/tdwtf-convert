require File.expand_path(File.dirname(__FILE__) + '/base.rb')

require 'csv'

class ImportScripts::CommunityServer < ImportScripts::Base
  def initialize
    super
  end

  def execute
    @avatars = {}
    users = CSV.read('tdwtf-users.csv', headers: true)
    create_users(users) do |u|
      avatar = u.delete('avatar').first
      @avatars[u['id']] = avatar.unpack('H*').first unless avatar == 'NULL'
      ActiveSupport::HashWithIndifferentAccess.new u.to_hash
    end

    @avatars.each do |id, a|
      u = user_id_from_imported_user_id(id)
      unless u.has_uploaded_avatar
        u.create_user_avatar(user_id: u.id) unless user.user_avatar
        u.user_avatar.uploaded_avatar = u.uploaded_avatar = Upload.create_for(u.id, StringIO.new(a), 'community-server-avatar.jpg', a.size)
        u.user_avatar.save!
        u.save!
      end
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
