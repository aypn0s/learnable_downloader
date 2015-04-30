require 'mechanize'
require 'fileutils'

print "Gimme email: "
user = gets.strip
print "Gimme password: "
pass = gets.strip
print "Where to start from (1 is first): "
start_from = gets.strip

agent = Mechanize.new
page  = agent.get 'https://learnable.com'

form = page.form_with id: 'new_user'
form['user[login]'] = user
form['user[password]'] = pass
form.submit

print 'Gimme course url: '
course_url = gets.strip
course_index = agent.get course_url
courses = course_index.links.select{|a| a.uri.to_s.match('step') }
folder_name = course_url.split('/').last
FileUtils.mkdir_p folder_name

courses.each_with_index do |c, i|
  if i + 1 >= start_from.to_i
    puts c.uri
    video_name = c.attributes['title']
    page = c.click
    if page.body.match(/mp4_hd_url(.*)mp4/)
      if page.body.match(/mp4_hd_url(.*)mp4/)[0].split('mp4_hd').first.include?('.mp4')
        video = page.body.match(/mp4_hd_url(.*)mp4/)[0].split('mp4_hd').first.match(/https:(.*)mp4/)[0]
      else
        video = page.body.match(/mp4_sd_url(.*)mp4/)[0].split('mp4_sd').last.match(/https:(.*)mp4/)[0]
      end
      system("wget #{video}")
      original_video_name = video.split('/').last
      FileUtils.mv original_video_name, "#{folder_name}/#{'%02d' % (i + 1)} #{video_name}.mp4"
      sleep 60
    end
  end
end


