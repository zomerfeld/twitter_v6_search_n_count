//REPLACE THESE WITH YOUR KEYS, SECRETS, TOKEN AND PIZZAS

void tConfigure() {

  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setOAuthConsumerKey("KEY");
  cb.setOAuthConsumerSecret("SECRET");
  cb.setOAuthAccessToken("ACCESSTOKEN");
  cb.setOAuthAccessTokenSecret("TOKENSECRET");
  cb.setUserStreamRepliesAllEnabled(false);

  //Twitter twitter = new TwitterFactory(cb.build()).getInstance();

  TwitterFactory tf = new TwitterFactory(cb.build());
  twitter = tf.getInstance();

}
