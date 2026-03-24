// Laban Effort Diagram — noisy waveforms on all 3 axes

float labanX, labanY, labanWidth, labanHeight;

float waveOffset1 = 0;
float waveOffset2 = 0;
float waveOffset3 = 0;

int wordIndex = 0;

String[] words = {
 // "Bound", "Free", "Strong", "Light", "Direct", "Indirect", "Sustained", "Quick",
  "Sensing & Feeling", "Intending & Progressing", "Thinking & Intuiting", "Attending & Deciding",
  "Sensing & Intuiting", "Intending & Deciding", "Feeling & Thinking", "Progressing & Attending",
  "Sensing & Thinking", "Intending & Attending"
};

void setup() {
  size(2000, 2000);
  labanX = 0;
  labanY = 200;
  labanWidth = 400;
  labanHeight = 400;
}

void draw() {
  background(0);
  pushMatrix();
  translate(labanX + labanWidth / 2, labanY + labanHeight / 2);
  rotate(HALF_PI); // 45 degrees clockwise
  translate(-(labanX + labanWidth / 2), -(labanY + labanHeight / 2));
  drawLabanDiagram(labanX, labanY, labanWidth, labanHeight);
  drawWaves();
  popMatrix();
  
  waveOffset1 += 0.34;
  waveOffset2 += 0.33;
  waveOffset3 += 0.35;
}

void drawWaves() {
  float cx = labanX + labanWidth / 2;
  float cy = labanY + labanHeight / 2;

  int steps = 80;
  float noiseScale = 0.5;
  float amp = 60; // how far the wave deviates from the axis

  noFill();

  // --- Vertical axis (Light/Strong) ---
  stroke(255, 255, 255, 160);
  beginShape();
  for (int i = 0; i <= steps; i++) {
    float t = (float) i / steps;
    float axisY = map(t, 0, 1, cy - labanHeight * 0.46, cy + labanHeight * 0.46);
    float n = noise(t * noiseScale, waveOffset1) - 0.5;
    float x = cx + n * amp * 2;
    strokeWeight(max(0.1, map(noise(t * 0.3, waveOffset1 * 0.5), 0, 1, 0.5, 6)));
    vertex(x, axisY);
  }
  endShape();

  // --- Horizontal axis (Free/Bound) ---
  stroke(255, 255, 255, 160);
  beginShape();
  for (int i = 0; i <= steps; i++) {
    float t = (float) i / steps;
    float axisX = map(t, 0, 1, cx - labanWidth * 0.47, cx + labanWidth * 0.47);
    float n = noise(t * noiseScale, waveOffset2) - 0.5;
    float y = cy + n * amp * 2;
    strokeWeight(max(0.1, map(noise(t * 0.3, waveOffset2 * 0.5), 0, 1, 0.5, 6)));
    vertex(axisX, y);
  }
  endShape();

  // --- Diagonal axis (Indirect/Direct) ---
  // Full axis: from back end to arrow end
  float dxFull = labanWidth  * 0.27 + labanWidth  * 0.086;
  float dyFull = -labanHeight * 0.14 - labanHeight * 0.044;
  float axisLen = sqrt(dxFull * dxFull + dyFull * dyFull);
  float ux = dxFull / axisLen;  // unit vector along axis
  float uy = dyFull / axisLen;
  float px = -uy;               // perpendicular
  float py =  ux;

  float startX = cx - labanWidth  * 0.086;
  float startY = cy + labanHeight * 0.044;

  stroke(255, 255, 255, 160);
  beginShape();
  for (int i = 0; i <= steps; i++) {
    float t = (float) i / steps;
    float ax = startX + ux * axisLen * t;
    float ay = startY + uy * axisLen * t;
    float n = noise(t * noiseScale, waveOffset3) - 0.5;
    float wx = ax + px * n * amp * 2;
    float wy = ay + py * n * amp * 2;
    strokeWeight(max(0.1, map(noise(t * 0.3, waveOffset3 * 0.5), 0, 1, 0.5, 6)));
    vertex(wx, wy);
  }
  endShape();
}

void drawLabanDiagram(float x, float y, float w, float h) {
  textSize(25);
  if (frameCount % int(random(30, 60)) == 0 ) { //(frameCount % 3 == 0 || frameCount % 47 == 0)
    wordIndex = int(random(words.length));
  }
  text(words[wordIndex], x+25, y);
  float cx = x + w / 2;
  float cy = y + h / 2;

  color g = color(0, 220, 80);

  float vLen  = h * 0.46;
  float hLen  = w * 0.47;
  float dxEnd = w * 0.27;
  float dyEnd = -h * 0.14;

  float labelSize   = h * 0.034;
  float qualitySize = h * 0.038;

  strokeWeight(2);
  stroke(g);

  line(cx, cy - vLen, cx, cy + vLen);
  drawArrow(cx, cy - vLen, cx, cy - vLen - 1, g);
  drawArrow(cx, cy + vLen, cx, cy + vLen + 1, g);

  line(cx - hLen, cy, cx + hLen, cy);
  drawArrow(cx - hLen, cy, cx - hLen - 1, cy, g);
  drawArrow(cx + hLen, cy, cx + hLen + 1, cy, g);

  line(cx, cy, cx + dxEnd, cy + dyEnd);
  line(cx, cy, cx - w * 0.086, cy + h * 0.044);
  drawArrow(cx + dxEnd, cy + dyEnd, cx + dxEnd + 1, cy + dyEnd - 1, g);

  fill(g);
  noStroke();
  textAlign(CENTER, CENTER);

  textSize(labelSize);
  text("Light",    cx,                           cy - vLen - labelSize * 1.4);
  text("Strong",   cx,                           cy + vLen + labelSize * 1.4);
  text("Free",     cx - hLen - labelSize * 2.2,  cy);
  text("Bound",    cx + hLen + labelSize * 2.2,  cy);
  text("Indirect", cx + w * 0.11,                cy - h * 0.22);
  text("Direct",   cx + dxEnd + labelSize * 2.8, cy + dyEnd);

  textSize(qualitySize);
  text("(Space)",  cx + w * 0.17, cy - h * 0.13);
  text("(Flow)",   cx + w * 0.22, cy + h * 0.04);

  textSize(labelSize);
  text("Sustained", cx - w * 0.16,  cy + h * 0.12);
  text("Quick",     cx + w * 0.086, cy + h * 0.12);

  stroke(g);
  strokeWeight(2);
  float dashY = cy + h * 0.145;
  line(cx - w * 0.205, dashY, cx - w * 0.115, dashY);
  line(cx + w * 0.054, dashY, cx + w * 0.126, dashY);

  noStroke();
  fill(g);
  textSize(qualitySize);
  text("(Time)",   cx - w * 0.145, cy + h * 0.20);
  text("(Weight)", cx,             cy + h * 0.34);
}

void drawArrow(float x1, float y1, float x2, float y2, color c) {
  stroke(c);
  fill(c);
  float angle     = atan2(y2 - y1, x2 - x1);
  float arrowSize = 9;
  pushMatrix();
  translate(x2, y2);
  rotate(angle);
  triangle(0, 0, -arrowSize, -arrowSize * 0.5, -arrowSize, arrowSize * 0.5);
  popMatrix();
}
