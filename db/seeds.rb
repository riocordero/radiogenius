# -*- coding: utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


station1 = Station.create({:url => 'http://google.com', :name => 'Station 1'})
station2 = Station.create({:url => 'http://google.com', :name => 'Station 2'})

songs = []
lady_gaga_songs = ['Bad Romance', 'Poker Face', 'Born This Way', 'Alejandro',
'Paparazzi', 'Marry the Night', 'The Edge of Glory', 'Judas', 'Lovegame',
'Monster', 'Just Dance', 'Dance in the Dark', 'Hair', 'Americano', 'Bloody
Mary', 'Yoü And I', 'Speechless', 'So Happy I Could Die', 'Government Hooker',
'Bad Kids', 'Boys Boys Boys', 'Heavy Metal Lover', 'Teeth', 'Beautiful, Dirty,
Rich', 'I Like It Rough', 'The Fame', 'Electric Chapel', 'Eh, Eh (Nothing Else I
Can Say)', 'Money Honey', 'Brown Eyes', 'Scheiße', 'Telephone', 'Highway Unicorn
(Road to Love)', 'Summerboy', 'Paper Gangsta', 'You And I', 'Fashion of His
Love', 'Telephone (feat. Beyoncé)', 'The Queen', 'Disco Heaven', 'Starstruck',
'ScheiBe', 'Again Again', 'Fashion', 'Marry The Night (Zedd Remix)', 'Black
Jesus + Amen Fashion', 'Judas (DJ White Shadow Remix)', 'Black Jesus - Amen
Fashion', 'Born This Way (Country Road Version)', 'Love Game']
lady_gaga_songs.each do |song|
  songs << ['Lady Gaga', song]
end

radiohead_songs = ['Karma Police',
'Creep',
'Paranoid Android',
'No Surprises',
'Lotus Flower',
'High And Dry',
'Fake Plastic Trees',
'Everything In Its Right Place',
'Airbag',
'Let Down',
'Exit Music (For A Film)',
'Reckoner',
'Idioteque',
'All I Need',
'Lucky',
'15 Step',
'Subterranean Homesick Alien',
'Bodysnatchers',
'Jigsaw Falling into Place',
'Just',
'House of Cards',
'Nude',
'Bloom',
'Codex',
'Street Spirit (Fade Out)',
'The National Anthem',
'Pyramid Song',
'Kid A',
'Electioneering',
'Climbing Up The Walls',
'Optimistic',
'Little By Little',
'Faust Arp',
'My Iron Lung',
'Videotape',
'The Bends',
'Weird Fishes/Arpeggi',
'Feral',
'Separator',
'Give Up the Ghost',
'Fitter Happier',
'The Tourist',
'Morning Mr Magpie',
'Planet Telex',
'Treefingers',
'I Might Be Wrong',
'Knives Out',
'How To Disappear Completely',
'Morning Bell',
'In Limbo']
radiohead_songs.each do |song|
  songs << ['Radiohead', song]
end

kanye_songs = [
'All of the Lights',
'Stronger',
'Power',
'Heartless',
'Dark Fantasy',
'Can\'t Tell Me Nothing',
'All of the Lights (interlude)',
'Love Lockdown',
'Hell of a Life',
'Who Will Survive in America',
'Jesus Walks',
'Gold Digger',
'Champion',
'Monster',
'Through The Wire',
'I Wonder',
'Street Lights',
'The Glory',
'Runaway',
'Lost In The World',
'Homecoming',
'RoboCop',
'Mercy',
'Coldest Winter',
'Flashing Lights',
'All Falls Down',
'Say You Will',
'Big Brother',
'Good Life',
'Touch The Sky',
'The New Workout Plan',
'Devil In A New Dress',
'Good Morning',
'Bad News',
'We Don\'t Care',
'Hey Mama',
'I\'ll Fly Away',
'Everything I Am',
'Monster (feat. Jay-Z, Rick Ross, Nicki Minaj & Bon Iver)',
'Runaway (feat. Pusha T)',
'Family Business',
'Blame Game',
'School Spirit',
'Gold Digger (feat. Jamie Foxx)',
'Graduation Day',
'Workout Plan',
'Flashing Lights (ft. Dwele)',
'Roses',
'Addiction',
'Amazing']
kanye_songs.each do |song|
  songs << ['Kanye', song]
end

1000.times do |index|
  artist, song = songs.sample
  station = index % 2 == 0 ? station1 : station2

  Play.create(:artist => artist,
              :song_title => song,
              :start_time => (index * 3).minutes.ago,
              :station_id => station.id)
end
