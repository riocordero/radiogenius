# Load the rails application
require File.expand_path('../application', __FILE__)

SEO_KEYWORDS = ['radio', 'music', 'music search engine', 'radio search engine', 'internet radio', 'online radio', 'free music', 'free online music', 'free songs', 'streaming music', 'shoutcast', 'mp3', 'pandora', 'top 40', 'tunein', 'iheartradio'].freeze

# Initialize the rails application
Radiogenius::Application.initialize!
