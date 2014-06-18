require File.expand_path(File.dirname(__FILE__) + '/base.rb')

require 'tempfile'
require 'csv'

class ImportScripts::CommunityServer < ImportScripts::Base
  def initialize
    super
  end

  def execute
    @avatars = {}
    users = CSV.read('tdwtf-users.csv', headers: true)
    create_users(users) do |u|
      avatar = u.delete('avatar').last
      @avatars[u['id']] = avatar.unpack('H*').first unless avatar == 'NULL'
      ActiveSupport::HashWithIndifferentAccess.new u.to_hash
    end

    puts '', 'uploading avatars'
    i = 0
    @avatars.each do |id, a|
      print_status i, @avatars.size
      i += 1

      id = user_id_from_imported_user_id(id)
      next unless id
      u = User.find(id)

      unless u.has_uploaded_avatar
        u.create_user_avatar(user_id: u.id) unless u.user_avatar
        f = Tempfile.new('csavatar')
        f.write(a)
        f.close
        u.user_avatar.custom_upload = u.uploaded_avatar = Upload.create_for(u.id, f.path, 'community-server-avatar.jpg', a.size)
        f.unlink
        u.user_avatar.save!
        u.save!
      end
    end
    print_status i, @avatars.size
    puts

    # begin specific to TDWTF
    {'18' => 10, '16' => 13, '17' => 17, '19' => 14, '21' => 4}.each do |cs, dc|
      c = Category.find(dc)
      c.custom_fields['import_id'] = cs
      c.save!
      @categories[cs] = c
    end
    # end specific to TDWTF

    puts

    categories = CSV.read('tdwtf-categories.csv', headers: true)
    create_categories(categories) do |c|
      ActiveSupport::HashWithIndifferentAccess.new c.to_hash
    end

    puts '', 'counting posts'

    count = 0
    CSV.open('tdwtf-posts.csv', headers: true) do |posts|
      posts.each do |p|
        count += 1
        print_status count, p['id']
      end
    end

    @post_titles = {}

    CSV.open('tdwtf-posts.csv', headers: true) do |posts|
      create_posts(posts, total: count) do |p|
        @post_titles[p['id']] = p['title']
        if p['id'] == p['parent'] # first post in topic
          {
            id: p['id'],
            user_id: user_id_from_imported_user_id(p['author']),
            created_at: p['created_at'],
            raw: transform_post(p['raw'], p['tags']),
            title: p['title'],
            category: category_from_imported_category_id(p['category']).id,
            meta_data: {'import_id' => p['topic']}
          }
        else
          {
            id: p['id'],
            user_id: user_id_from_imported_user_id(p['author']),
            created_at: p['created_at'],
            raw: transform_post(p['raw'], p['tags'], unless p['title'] == 'Re: ' + @post_titles[p['parent']].gsub(/^Re: /, '') then p['title'] end),
            title: p['title'],
            category: category_from_imported_category_id(p['category']).id
          }
        end
      end
    end
  end

  def transform_post raw, tags, title=nil
    raw.gsub!(/([\*#_`])/, '\\\1')
    raw.gsub!("[quote user=\"", "[quote=\"")
    if title
      raw = "##{title}\n\n#{raw}"
    end
    unless tags.empty?
      raw += "\n\n---\nFiled under: [#{tags.split(', ').join('](#tag), [')}](#tag)\n"
    end
  end
end

ImportScripts::CommunityServer.new.perform
