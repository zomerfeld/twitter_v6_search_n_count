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

// Extract TWEETS - SAVE TO FILE ////////////////////////////////////////////

void extractTweets(String user) {
  int userIndexRow = nameTable.findRowIndex(user, 1); //finds the index row for the user
  TableRow result = nameTable.findRow(user, 1);
  String lastID_user = result.getString(2);  
  String lastID_user_processed = result.getString(3);
  filename = "indexed/" + user + ".txt"; 

// *** SORTING HERE IS BROKEN - I GET WRONG NUMBERS IN NAMES.TSV 

  for (TableRow row : dataTable.findRows(user, 0)) {
    if (Long.parseLong(row.getString(1)) > Long.parseLong(lastID_user_processed)) { //only process unprocessed tweets
     println("found new tweet");
     println(Long.parseLong(row.getString(1)) + "is larger than: " + Long.parseLong(lastID_user_processed));
     nameTable.setString(userIndexRow, 3, row.getString(1));
//      println(row.getString(1) + ": " + row.getString(3)); //Prints all the tweets to the console
      appendTextToFile(filename, row.getString(3)); //Put tweet into the plain text file.
    }
  }
  //COUNT numbers of lines in files
  lastID_user_processed = result.getString(3);
  File f = new File(dataPath(filename));
  if (f.exists()) {
    String lines[] = loadStrings(filename);
    println("there are " + lines.length + " lines");
  } else {
    println("no new tweets to put in " + filename);
  }


  //update names.tsv 4th column with last tweet extracted
  nameTable.setString(userIndexRow, 3, lastID_user_processed);
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
  File f = new File(dataPath(file));
  if (f.exists()) {
    String[] stopWords = loadStrings("StopWords.txt"); //Loads Stop Words File
    println("stopWords loaded");
    String[] data = loadStrings(file);
    println("strings loaded");
    StringBuilder strBuilder = new StringBuilder();

    for (int i=0; i<data.length; i++) {
      //  data[i] = data[i].toLowerCase().replaceAll("\\W", " ").replaceAll(" +", " ");
      data[i] = data[i].toLowerCase();

      strBuilder.append( data[i] );
      //println("tweets stored in data array");
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
    while (it.hasNext()) //Commenting it out to see if I can change it to an if
    { //Saves it all to the tsv file
      String key = (String) it.next(); 
      NameAndNumber nan = (NameAndNumber) map.get(key);
      //println(key + " -> " + nan.m_number); //prints all sorted words if you uncomment
      appendTextToFile(file+"_weighted.tsv", key + "\t" + nan.m_number); //Put tweet into the plain text file.
      ////Trying to add a visualization for each user *************************
      //fill(0.1 * nan.m_number);
      //textSize(nan.m_number/10 +0.1);
      //text(key, random(width-50), random(height)); //prints tweet on screen
      //// end of visualization **************************************************
      count++;
    }

    return;
  } else {
    println("No file to make wordtable with");
  }
}

  // FIND THE MAX IDS IN THE TWEETS TSV FILE and store them in column 2 (the 3rd) in names.tsv  ////////////////////////////////////////////


  void maxID() {

    HashMap<String, Long> users = new HashMap<String, Long>(); //Creates a hashmap to sort this out

    for (int row = 0; row < nameTable.getRowCount(); row++) { 
      String userName = nameTable.getString(row, 1); //gets all the usernames from the nametable
      users.put(userName, (long) 1); //stores them in the users hashmap
    }

    for (int row = 0; row < dataTable.getRowCount(); row++) { //goes over all the lines in the datatable
      String userName = dataTable.getString(row, 0); //gets the username from the line in the table
      Long lastTweetId = Long.parseLong(dataTable.getString(row, 1)); //gets the ID from the data table

      if (users.get(userName) < lastTweetId) { //if the last id in the namestable is smaller
        users.put(userName, lastTweetId); //save the last tweet id
        println("this is larger: " + lastTweetId);
      }
    } 
    //stores the hashmap last ID to column 2 in the names.tsv
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


  void drawWord (String dword, float dweight, float dMax, float dMin) {
    float dweightNorm = map(dweight, dMax, dMin, 1, 120);
    fill(255, 255, 0);
    textSize(dweightNorm/10 +0.1);
    text(dword, random(width-50), random(height)); //prints tweet on screen
    println(dword);
    delay(1);
  }


  // ************** DELETE FILES ******************************************

  void deleteFile(String file) {
    String fileNameD = file;
    // A File object to represent the filename
    File f = new File(fileNameD);

    // Make sure the file or directory exists and isn't write protected
    if (!f.exists())
      println("Delete: no such file or directory: " + fileNameD);

    if (!f.canWrite())
      println("Delete: write protected: " + fileNameD);

    // If it is a directory, make sure it is empty
    if (f.isDirectory()) {
      String[] files = f.list();
      if (files.length > 0)
        println("Delete: directory not empty: " + fileNameD);
    }

    // Attempt to delete it
    boolean success = f.delete();

    if (!success) {
      println("Delete: deletion failed");
    }
  }