
ArrayList<Ball> balls;
int time = 0;            // Game time
//int minute, second;    
int scoreP1 = 0;          //player 1 score (human)
int scoreP2 = 0;          //player 2 score (computer)
int totalBalls;       //total number of balls in the whole game
int ballNum;         //Total number of balls not yet shown up in the field
int fps;              //frames per second
int maxTime;        //game time (3 minutes by default)
int gateLeft = 225;          // left boundaries of goal
int gateRight = 375;        // right boundaries of goal
int p2Bound;          // Upper boundary for player 1, player1 cannot move across this line
int p1Bound;           // Lower boundary for player 2.
int top;         //Top margin of game field
int bottom;      //Bottom margin of game field
int goalDepth = 20; //Each goal is 20 in depth
boolean gameOver = false;      //when gameOver == true, game is over
int leftMargin = 50;  //left margin that confines the keeper
Keeper p1;            //player1 (human)
Keeper p2;            //player2 (computer)


public void setup() {
  //Initialize parameters that are frequently changed for gaming test purpose
  size(600, 800);     //By default, height == 800, width == 600, field length == 700
  top = 50;                // Top margin as outside of game field to show all information
  bottom = height - top;    // bottom = 850
  totalBalls = 5;          //total number of balls in a game
  ballNum = totalBalls;         //Total number of balls not yet shown up in the field
  p1Bound = bottom - 200;          // Upper boundary for player 1, player1 cannot move across this line, 600 by default
  p2Bound = 200 + top;             // Lower boundary for player 2. 250 by default

  fps = 100;              //frames per second
  frameRate(fps);
  maxTime = 1 * 60 * fps;    //game time (1 minutes by default)
  
  balls = new ArrayList();        //list of all balls
  p1 = new Keeper(width / 2, bottom - 100, p1Bound, bottom, leftMargin, 0, 0);
  //player 1 can only move inside penalty area at the bottom
  p2 = new Keeper(width / 2, top + 50, top, p2Bound, leftMargin, fps / 20, 0);   
  //player2 can only move inside penalty area at the top

}

public void draw() {
  drawBackground();
  if (ballNum > 0 && time % (maxTime / (totalBalls * 2)) == 0) addBall(); //balls will show up by the same time interval
  if (p1.score + p2.score == totalBalls - ballNum) addBall(); // when there is no ball on the field
  
  time += 1; 

  p1.moveByMouse();   //human player makes move
  p2.moveComputer();  // Computer makes move
  moveBalls();        //balls move based on updated keeper positions

//after all moves are made and positions updated, draw the goal keepers and balls
  p1.drawKeeper();    
  p2.drawKeeper();
  drawBalls();

//draw scores, time left, and balls not yet goaled
  drawScore();       
  drawTime();
  drawBallsLeft();
  
// Game over check
  //gameOver = ;
  if (isGameOver()) {
    drawEnding(); // to draw what it is like when game over
    noLoop();
    return;
  }
}

private void addBall() { // add a new ball to the field, decrease # of unshown balls by 1
  balls.add(new Ball(p2Bound, p1Bound));
  ballNum--;
}

private void drawBackground() {
  // draw background layouts
  background(83, 214, 43); // green grass background
  fill(0);
  noStroke();
  rect(0, 0, width, top); // black margin
  rect(0, bottom, width, top);  //black margin
  
  // Draw the two goals in grey
  fill(180); 
  rect(gateLeft, top - goalDepth, gateRight - gateLeft, goalDepth); 
  rect(gateLeft, bottom, gateRight - gateLeft, goalDepth); 
  
  // draw the white lines of penalty areas
  stroke(250);
  strokeWeight(5);
  noFill();
  beginShape();
  vertex(leftMargin, top);
  vertex(leftMargin, p2Bound);
  vertex(width - leftMargin, p2Bound);
  vertex(width - leftMargin, top);
  endShape();
  beginShape();
  vertex(leftMargin, bottom);
  vertex(leftMargin, p1Bound);
  vertex(width - leftMargin, p1Bound);
  vertex(width - leftMargin, bottom);
  endShape();
  noStroke();
}

boolean isGameOver() {                                //return true if game over
  if (p1.score + p2.score == totalBalls) return true; //when all balls are goal
  if (time >= maxTime) return true;                    //when time ends
  return false;
}

void drawBalls() {                  //draw all balls
  for (Ball ball : balls) {
    if (!ball.isGoal) ball.drawBall();
  }
}

void moveBalls() {                //move all balls
  for (Ball ball : balls) {
    if (!ball.isGoal) ball.moveBall();
  }
}

void drawScore() {            //show scores of both sides
  fill(220);
  textSize(24);
  text("Your Score: " + p1.score, 20, bottom + goalDepth);
  text("PC's Score: " + p2.score, 20, top - goalDepth);
}

void drawEnding() {          //draw results when game over
  fill(0, 0, 0);
  textSize(40);
  textAlign(CENTER);
  text("Game Over!", width / 2, height / 2);
  if (p1.score > p2.score) text("Congratulations! You Win!", width / 2, height / 2 + 50);
  else if (p2.score > p1.score) text("The Computer Wins!", width / 2, height / 2 + 50);
  else text("The Game Is A Draw!", width / 2, height / 2 + 50);
  textAlign(LEFT);
}

void drawTime() {                         //draw time count down
  fill(220);
  textSize(24);
  int timeLeft = maxTime - time;
  int minute = timeLeft / (60 * fps);               //minutes and second count down
  int second = timeLeft / fps - minute * 60;
  String sec = "" + second; // convert to string
  if (second < 10) sec = "0" + sec;
  text("Time " + minute + ":" + sec, gateRight + 20, bottom + goalDepth);
}

void drawBallsLeft() {                          //draw how many balls are not yet goaled
  fill(220);
  textSize(24);
  text("Total Balls: " + (totalBalls - p1.score - p2.score), gateRight + 20, top - goalDepth);
}


