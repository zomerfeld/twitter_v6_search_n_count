// GET NEW TWEETS ////////////////////////////////////////////

void getNewTweets(String searchUser, long whatever) {
  while (true) {

    try {
      size = tweets.size(); 
      println("searching this user in the name table: " + searchUser);
      TableRow result = nameTable.findRow(searchUser, 1);
      long searchSince = Long.parseLong(result.getString(2));
      println("this is the sinceID from names.tsv: " + searchSince);
      Paging page = new Paging(pageno, 100).sinceId(searchSince);
      tweets.addAll(twitter.getUserTimeline(searchUser, page));
      println("GET - getting new tweets, page number " + pageno);
      pageno++;
      //if (tweets.size() == size || pageno == 5) //limit to 5 to save on API limit - TEST, comment out this line and uncomment the next
      if (tweets.size() == size) // Unlimited - max amount of tweets (3200) //uncomment for PROD
        break;
    }
    catch(TwitterException te) {
      System.out.println("Failed to search tweets: " + te.getMessage());
      System.exit(-1);
      te.printStackTrace();
    }
  }

  System.out.println("Total: "+tweets.size());
}


// PROCESS TWEETS - SAVE TO FILE AND DISPLAY ////////////////////////////////////////////

void processTweets() {
}


// CREATE AND APPEND TO TEXT FILE ////////////////////////////////////////////


void appendTextToFile(String filename, String text) {
  File f = new File(dataPath(filename));
  if (!f.exists()) {
    createFile(f);
  }
  try {
    PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
    out.println(text);
    out.close();
  }
  catch (IOException e) {
    e.printStackTrace();
  }
}

/**
 * Creates a new file including all subfolders
 */
void createFile(File f) {
  File parentDir = f.getParentFile();
  try {
    parentDir.mkdirs(); 
    f.createNewFile();
  }
  catch(Exception e) {
    e.printStackTrace();
  }
} 

// REFRESH THE DISPLAY ////////////////////////////////////////////

void keyPressed( ) {
  if ((key == 'Z') || (key == 'z')) {
    currentTweet = 0;
    loop();
  }
}

// MAKE WORD TABLE ////////////////////////////////////////////


void makeWordTable(String file) {
  String[] stopWords = loadStrings("StopWords.txt"); //Loads Stop Words File
  //println(stopWords);
  String[] data = loadStrings(file);
  StringBuilder strBuilder = new StringBuilder();
  for (int i=0; i<data.length; i++) {
    //  data[i] = data[i].toLowerCase().replaceAll("\\W", " ").replaceAll(" +", " ");
    data[i] = data[i].toLowerCase();

    strBuilder.append( data[i] );
    //println(data[i]);
  }


  String dataOne = strBuilder.toString();
  //String[] names = dataOne.replaceAll("\\W", " ").replaceAll(" +", " ").split(" "); //maybe removing this will get rid of the parts that remove apostrophes
  String[] names = dataOne.replaceAll("#", " ").replaceAll("\"", " ").replaceAll("@", " ").replaceAll("\\.", " ").replaceAll(", ", " ").replaceAll("! ", " ").replaceAll(":", " ").replaceAll("\\[", " ").replaceAll("\\]", " ").replaceAll("\\)", " ").replaceAll("\\/\\/", " ").split(" ");
  Map map = new HashMap();

  for (int i = 0; i < names.length; i++)
    if (Arrays.asList(stopWords).contains(names[i])) {
      //println ("ignored");
    } else {
      {
        String key = names[i];
        NameAndNumber nan = (NameAndNumber) map.get(key);
        if (nan == null)
        {
          // New entry
          map.put(key, new NameAndNumber(key, 1));
        } else
        {
          map.put(key, new NameAndNumber(key, nan.m_number + 1));
        }
      }
    }

  // Sort the collection
  ArrayList keys = new ArrayList(map.keySet());
  Collections.sort(keys, new NameAndNumberComparator(map));

  // List the top (ten)
  int MAX = 10; 
  int count = 0;
  Iterator it = keys.iterator();
//  while (it.hasNext() && count < MAX) //Original with max of 10
  while (it.hasNext())

  {
    String key = (String) it.next();
    NameAndNumber nan = (NameAndNumber) map.get(key);
    //println(key + " -> " + nan.m_number); //prints all sorted words if you uncomment
    appendTextToFile(file+"_weighted.tsv", key + "\t" + nan.m_number); //Put tweet into the plain text file.
    count++;
  }

  return;
}


// FIND THE MAX IDS IN THE TWEETS TSV FILE ////////////////////////////////////////////


void maxID() {

  HashMap<String, Long> users = new HashMap<String, Long>();
  for (int row = 0; row < nameTable.getRowCount(); row++) {
    String userName = nameTable.getString(row, 1);
    users.put(userName, (long) 1);
  }

  for (int row = 0; row < dataTable.getRowCount(); row++) {
    String userName = dataTable.getString(row, 0);
    Long lastTweetId = Long.parseLong(dataTable.getString(row, 1));

    if (users.get(userName) < lastTweetId) {
      users.put(userName, lastTweetId);
      println("this is larger: " + lastTweetId);
    }
  } 

  for (String userName : users.keySet()) {
    println(userName + ": " + users.get(userName));
    for (int i = 0; i < nameTable.getRowCount(); i++) {
      if (nameTable.getString(i, 1).equals(userName)) {
        //println(i + userName + (users.get(userName)).toString());
        nameTable.setString(i, 2, (users.get(userName)).toString());
        //println(nameTable.getString(i,2));
        saveTable(nameTable, "data/names.tsv");
      }
    }
  }
}