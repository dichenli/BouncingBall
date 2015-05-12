//start of class keeper and class ball
class Keeper {
  float x, y, dx, dy;        // x and y are positions, dx and dy are positions changing rate (dx = v_x * dt)
  int diameter = 40;          //keeper diameter
  int radius = diameter / 2;
  //bounds: moving ranges of keeper (the penalty area)
  int upperBound;              
  int lowerBound;
  int leftBound;
  int rightBound;
  int score;      //score of the keeper 

  public Keeper(float initX, float initY, int upper, int lower, int left, float initDX, float initDY) {
    x = initX;
    y = initY;
    dx = initDX;
    dy = initDY;
    upperBound = upper;
    lowerBound = lower;
    leftBound = left;
    rightBound = width - left;
    score = 0;
  }  

  public void drawKeeper() {
    noStroke();
    fill(255, 100, 100);
    ellipse(x, y, diameter, diameter);
  }

  public void moveByMouse() {
    dx = ease(mouseX - x);
    dy = ease(mouseY - y);
    
    //if it collides with bounds, stop it
    if ((x <= leftBound + radius && dx < 0) || (x >= rightBound - radius && dx >0)) dx = 0;  
    if ((y <= upperBound + radius && dy < 0) || (y >= lowerBound - radius && dy > 0)) dy = 0;
    
    //update position
    x += dx;
    y += dy;
    
    //if the ball moves outside of bound, drag it back
    if (y < upperBound + radius) y = upperBound + radius;
    if (y > lowerBound - radius) y = lowerBound - radius;
    if (x < leftBound + radius) x = leftBound + radius;
    if (x > rightBound - radius) x = rightBound - radius;
  }

  private float ease(float n) {  // adjust easing factor to change game difficulty
    return n / 1.0;
  }

  public void moveComputer() {   //computer controls the keeper to move periodically
    if (x <= gateLeft || x >= gateRight) dx = - dx;
    x += dx;
    y += dy;
  }
} //End of class Keeper




class Ball {
  float x, y, dx, dy;         // x and y are positions, dx and dy are positions changing rate (dx = v_x * dt)
  int diameter = 20;
  int radius = diameter / 2;
  boolean isGoal = false;        //if the ball goals
  float maxSpeed = 5.0;          //maximum speed allowed for ball movement

  public Ball(int upperBound, int lowerBound) {
    //generate the ball at random position and speed, originated from middle area of field
    x = random(width);
    y = random(upperBound, lowerBound);    

    do {
      dx = random(- maxSpeed, maxSpeed);
      dy = random(- maxSpeed, maxSpeed);
    } 
    while (dy > -0.3 * maxSpeed && dy < 0.3 * maxSpeed);      //ball initial speed shouldn't be too slow
  }


  public void drawBall() {
    if (isGoal) return;
    fill(255);
    ellipse(x, y, diameter, diameter);
  }

  private boolean[] bounceKeeper(Keeper keeper) { //deal with the case if the ball will collide with a keeper
    float rx = this.x - keeper.x; //rx and ry: relative distance from ball to keeper
    float ry = this.y - keeper.y;
    boolean contactKeeper = sqrt(rx * rx + ry * ry) <= keeper.radius + this.radius;
    //whether the ball is in contact with keeper
    boolean[] bounceXY = {
      false, false
    };  
    // the x and y directions are normal to each other so should be dealt with separately
    if (contactKeeper) {
      float rdx = this.dx - keeper.dx; // rdx and rdy: speed of ball relative to the keeper
      float rdy = this.dy - keeper.dy;
      if (rx * rdx < 0) {                //if the ball moves towords keeper in x direction
        this.dx = keeper.dx * 2 - this.dx;
        bounceXY[0] = true;
      }
      if (ry * rdy < 0) {                //if the ball moves towords keeper in y
        this.dy = keeper.dy * 2 - this.dy;
        bounceXY[1] = true;
      }
      // if ball is in contact with the keeper but is leaving the keeper, then the speed of the ball should not change
    }
    return bounceXY;
  }

  private boolean[] bounceWall() { //deal with the case if the ball will collide with wall
    boolean[] bounceXY = {false, false};  
    
    //if the position of ball is at the wall and moving towards the wall
    if ((x <= radius && dx < 0) || (x >= width - radius && dx >0)) { 
      dx = -dx;
      bounceXY[0] = true;
    }
    if ((y <= top + radius && dy < 0) || (y >= bottom - radius && dy > 0)) {
      dy = -dy;      
      bounceXY[1] = true;
    }
    return bounceXY;
  }

  public void moveBall() {
    isGoal = goal(); //this is necessary because goal() shouldn't be called other than in this place, but isGoal is called in main function
    if (isGoal) { 
      removeBall(); 
      return;
    } //if is goal, the ball should not move anymore
    
    boolean[] bounceKeeperXY = bounceKeeper(p1);  //if the ball will collide with player 1 from X or Y direction
    if (!bounceKeeperXY[0] && !bounceKeeperXY[1]) bounceKeeperXY = bounceKeeper(p2); //if the ball will collide with player 2
    boolean[] bounceWallXY = bounceWall();
    if (bounceKeeperXY[0] && bounceWallXY[0]) dx = 0; // if the ball bounce at wall and keeper simultaneously on x direction
    if (bounceKeeperXY[1] && bounceWallXY[1]) dy = 0; // if the ball bounce at wall and keeper simultaneously on y direction
    if (dx == 0 && dy == 0) dx = dy = random(-1, 1); //if the ball stops completely, give it a random small speed
    if (dx >= maxSpeed) dx = dx * 0.99; //if the ball moves too fast
    if (dy >= maxSpeed) dy = dx * 0.99; 
    x += dx;
    y += dy;
    if (y < top + radius && !inGoalArea()) y = top + radius; // Do not left the ball cross boundary
    if (y > bottom - radius && !inGoalArea()) y = bottom - radius;
    if (x < 0 + radius) x = 0 + radius;
    if (x > width - radius) x = width - radius;
  }
  
  private boolean inGoalArea() {  //whether the ball is in goal
    return x <= gateRight + radius && x >= gateLeft - radius;
  }
  
  private boolean goal() {
    if ((y <= top + radius) && inGoalArea()) return true;
    //p1 score when the ball goal in p2's
    else if ((y >= bottom - radius) && inGoalArea()) return true;
    else return false; //no goal
  }

  public void removeBall() { //move away the ball, and also assign score to players
    if (y <= top + radius) { 
      p1.score += 1; 
      y = top - goalDepth;
    } else if (y >= bottom - radius) { 
      p2.score += 1; 
      y = bottom + goalDepth;
    }
    dx = 0;
    dy = 0;
  }
} //End of class Ball

