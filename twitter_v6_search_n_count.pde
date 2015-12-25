import java.util.*;
import twitter4j.*;
import twitter4j.conf.*;
import java.io.BufferedWriter;
import java.io.FileWriter;
import wordcram.*; // I don't think I need this anymore
import java.io.*; 

int size = 0;
int pageno = 1;
int currentTweet;
String user;
List<Status> tweets = new ArrayList<Status>();
String fileStore;
String timeString;
String wordsTable;
String tsvOutput;
String filename;
ArrayList<String> files = new ArrayList<String>();
Table nameTable;
Table dataTable;
Table countedTable;
int currentRow = -1;
PrintWriter writer;
int rowCount = 0;
int DataRowCount;
long lastID = 1;
Twitter twitter;
PFont f;
long time;
int wait = 100;
Table weightTable;
int wRowCount =0;



void setup() {
  //frameRate(10);
  size(800, 600);
  timeString = year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second(); //GET TIME
  println(timeString); // PRINT TIME
  fileStore = "tweets"; //plain text file
  tsvOutput = fileStore + ".tsv"; //tweets.tsv file (currently taking the name from the plain text version
  println("plain text file: " + tsvOutput); // Prints the raw text tweet file location
  wordsTable = user + "_"+timeString + "weighted.txt"; //Where to save the weighted Tweets
  nameTable = loadTable("names.tsv", "tsv"); //the tables where the usernames and last IDs is saved
  dataTable = loadTable(tsvOutput, "tsv"); //The table where the tweets will be saved
  countedTable = new Table();
  tConfigure(); // Configures Twitter Authentication. The configure function is in a separate file that doesn't go on github.

  //configs for visualization:
  time = millis();//store the current time
  f = createFont("Arial", 20, true);
  textFont(f);

  //end configs for visualization

  // ROW COUNT 
  rowCount = nameTable.getRowCount();
  println("rowcount of name table is: " + rowCount);

  maxID(); //Goes over the tweets tsv file, and stores the last values in column 2 in names.tsv
}

void doitall() {
  if (currentRow < (rowCount -1) ) { //rowCount -1 because 0 is a number

    fill(0, 30);
    rect(0, 0, width, height); //fades the tweets from the screen by printing a semi-opaque black square on top of them

    currentRow++;
    println("Current Row in namestable: " + currentRow);

    //if there are more users to look up in the name table
    user = nameTable.getString(currentRow, 1); //gets the username from the name table
    extractTweets(user); // puts tweets from that user in txt file
    println("tweets extracted");
    makeWordTable(filename); //takes tweets, counts words and add it into a tsv
    files.add(filename + "_weighted.tsv");

    String filenameToDelete = dataPath(filename); //get full path of file
    println("filename is: " + filenameToDelete);
    deleteFile(filenameToDelete); //Delete txt file of tweets after processing
  
    println("word table made");
  }
}

void draw() {
  time = millis();//store the current time
  doitall();

  if (currentRow == (rowCount - 1)) { //when DONE
    saveTable(nameTable, "data/names.tsv"); //only save table when the sketch is done
    
    
    ////Trying to add a visualization for each user *************************
    for (int i = 0; i<files.size(); i++) {
      String wTable = files.get(i);
      float dataMin = MAX_FLOAT;
      float dataMax = MIN_FLOAT;
      weightTable = loadTable(wTable, "tsv"); //The table where the tweets will be saved
      int wRowCount = weightTable.getRowCount();
      for (int row = 0; row < wRowCount; row++) {
        float value = weightTable.getFloat(row, 1);
        if (value > dataMax) {
          dataMax = value;
        }
        if (value < dataMin) {
          dataMin = value;
        }
      }
      for (int row = 0; row < wRowCount; row++) {
        String word = weightTable.getString(row, 0);
        float weight = weightTable.getFloat(row, 1);
       // drawWord(word, weight, dataMax, dataMin); // The Draw Word function doesn't really work
      }
    }
    //fill(0.1 * nan.m_number);
    //textSize(nan.m_number/10 +0.1);
    //text(key, random(width-50), random(height)); //prints tweet on screen
    //// end of visualization **************************************************
    println("***DONEZO***");



    //noLoop();
  }

  //if (currentTweet < tweets.size()) { //combs over all the tweets in the memory from the get new tweets function
  //  Status status = tweets.get(currentTweet);
  //  println("current tweet: " + currentTweet);
  //  String str = status.getText();
  //  if (str.charAt(0) != '@') { //IGNORES replies and tweets that starts with mentions
  //    String getTextSani = status.getText().replaceAll("(\\r|\\n)", "  "); //removes break lines from tweets - how wonderful
  //    appendTextToFile(fileStore, getTextSani); //Put tweet into the plain text file. 
  //    appendTextToFile(tsvOutput, (user + "\t" + status.getId() + "\t" + status.getCreatedAt() + "\t" + getTextSani)); //puts tweets (and user, tweet ID and date+time) into the TSV file
  //    fill(200);
  //    text(getTextSani, random(width-300), random(height-150), 300, 200); //prints tweet on screen
  //    delay(2);
  //  }
  //  currentTweet = currentTweet + 1; //Moves to the next tweet
  //} else { //if all tweets in memory are processed or there are no tweets in memory
  //  println("clearing and moving row");
  //  tweets.clear(); //remove all tweets from memory (if it's not already empty)
  //  currentRow++; // moves one row in the names.tsv (nameTable)
  //  pageno = 1; //sets the page to be 1 again, to start retrieving tweets from another user
  //  currentTweet = 0; // resets the tweet count to 0
  //  println("current row in name table: " + currentRow);
  //  println("currentTweet in memory: " + currentTweet);
  //  println("tweets.size (total tweets in mem): " + tweets.size());

  //  if (currentRow < rowCount) { //if there are more users to look up in name table
  //    user = nameTable.getString(currentRow, 1); //gets the username from the name table
  //    DataRowCount = dataTable.getRowCount(); //counts the rows in the tweets table


  //    println("now retrieving: " + user);
  //    getNewTweets(user, 1); //Gets tweets to memory (1 is fake number, real number retrieval for sinceID is done in the actual maxID() function
  //    //processTweets(); //doesn't do anything, empty function. Keeping it here just in the meantime
  //  }
  //}

  //if (currentRow > rowCount) { //When there are no new tweets anymore
  //  maxID(); // updates names.tsv with the last ids in tweets.tsv
  //  noLoop(); //stops the loop
  //  println("***DONEZO***");
  //}
}