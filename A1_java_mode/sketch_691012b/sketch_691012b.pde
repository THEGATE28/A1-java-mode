// ==============================================================================
// Project: Projectile Motion Simulator (Physics Interactive Animation)
// Mode: Processing (Java Mode)
// ==============================================================================

// --- ค่าคงที่และตัวแปรหลักทางฟิสิกส์ ---
float g = 9.8;           // ค่าความเร่งโน้มถ่วง (m/s^2)
float initial_velocity = 45.0; // ความเร็วต้น v0 (m/s)
float launch_angle = 45.0;     // มุมยิง theta (องศา)
float t = 0.0;                 // เวลาปัจจุบัน (s)
float dt = 0.035;              // delta t สำหรับการอัปเดตแต่ละเฟรม

float current_x = 0.0;
float current_y = 0.0;
boolean is_animating = false;
boolean is_finished = false;

// --- ผลลัพธ์การคำนวณ (Outputs) ---
float max_height = 0.0;
float max_range = 0.0;
float total_time = 0.0;

// --- รายการเก็บพิกัดสำหรับวาด Trajectory Line ---
ArrayList<Float> x_points = new ArrayList<Float>();
ArrayList<Float> y_points = new ArrayList<Float>();

// --- สเกลและพิกัดการแสดงผลบน Canvas ---
float origin_x = 90;
float origin_y = 530;
float scale_m = 1.7; // 1 เมตร = 1.7 พิกเซล

// --- ประกาศตัวแปร UI Controls ---
Slider slider_v;
Slider slider_angle;
Button btn_start;
Button btn_reset;


// --- คลาสจำลอง UI Controls (Slider & Button) ---
class Slider {
  float x, y, w, h;
  float min_v, max_v, val;
  String label, unit;
  boolean is_dragging = false;

  Slider(float x, float y, float w, float h, float min_v, float max_v, float default_v, String label, String unit) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.min_v = min_v;
    this.max_v = max_v;
    this.val = default_v;
    this.label = label;
    this.unit = unit;
  }

  void display() {
    // แถบพื้นหลัง
    fill(45, 48, 65);
    stroke(70, 75, 100);
    strokeWeight(1.5);
    rect(x, y, w, h, 6);

    // แถบความคืบหน้า
    float fill_w = map(val, min_v, max_v, 0, w);
    fill(66, 135, 245);
    rect(x, y, fill_w, h, 6);

    // ปุ่มเลื่อน (Knob)
    fill(255);
    stroke(40);
    ellipse(x + fill_w, y + h / 2.0, h + 8, h + 8);

    // ข้อความระบุค่า
    fill(220);
    textAlign(LEFT, CENTER);
    textSize(13);
    text(label + ": " + nf(val, 0, 1) + " " + unit, x, y - 12);
  }

  boolean is_hover() {
    return (mouseX >= x - 10 && mouseX <= x + w + 10 &&
            mouseY >= y - 10 && mouseY <= y + h + 10);
  }

  float update() {
    if (is_dragging) {
      float ratio = constrain((mouseX - x) / w, 0.0, 1.0);
      val = min_v + ratio * (max_v - min_v);
    }
    return val;
  }
}


class Button {
  float x, y, w, h;
  String label;
  color bg_color;

  Button(float x, float y, float w, float h, String label, color bg_color) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
    this.bg_color = bg_color;
  }

  void display() {
    if (is_hover()) {
      fill(red(bg_color) + 25, green(bg_color) + 25, blue(bg_color) + 25);
    } else {
      fill(bg_color);
    }
    noStroke();
    rect(x, y, w, h, 8);

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(14);
    text(label, x + w / 2.0, y + h / 2.0);
  }

  boolean is_hover() {
    return (mouseX >= x && mouseX <= x + w &&
            mouseY >= y && mouseY <= y + h);
  }
}


// --- ฟังก์ชันคำนวณทางฟิสิกส์ ---
PVector calculate_position(float v0, float angle, float time_val) {
  float rad = radians(angle);
  float vx = v0 * cos(rad);
  float vy = v0 * sin(rad);
  float x = vx * time_val;
  float y = (vy * time_val) - (0.5 * g * (time_val * time_val));
  return new PVector(x, y);
}

void calculate_theoretical_stats() {
  float rad = radians(launch_angle);
  float v_y = initial_velocity * sin(rad);

  total_time = (2.0 * v_y) / g;
  max_height = (v_y * v_y) / (2.0 * g);
  max_range = (initial_velocity * initial_velocity * sin(2.0 * rad)) / g;
}

void reset_simulation() {
  t = 0.0;
  current_x = 0.0;
  current_y = 0.0;
  is_animating = false;
  is_finished = false;
  x_points.clear();
  y_points.clear();
  x_points.add(0.0);
  y_points.add(0.0);
}

void update_animation() {
  if (launch_angle <= 0) {
    current_x = 0.0;
    current_y = 0.0;
    is_animating = false;
    is_finished = true;
    return;
  }

  t += dt;
  PVector pos = calculate_position(initial_velocity, launch_angle, t);

  if (pos.y <= 0) {
    current_y = 0.0;
    current_x = initial_velocity * cos(radians(launch_angle)) * total_time;
    is_animating = false;
    is_finished = true;
  } else {
    current_x = pos.x;
    current_y = pos.y;
  }

  x_points.add(current_x);
  y_points.add(current_y);
}


// --- ส่วนประมวลผลหลักของ Processing ---
void setup() {
  size(1050, 620);
  frameRate(60);

  slider_v = new Slider(80, 50, 180, 12, 10.0, 65.0, initial_velocity, "Initial Velocity (v0)", "m/s");
  slider_angle = new Slider(300, 50, 180, 12, 0.0, 90.0, launch_angle, "Launch Angle (theta)", "deg");
  btn_start = new Button(520, 38, 95, 34, "LAUNCH", color(0x22, 0xB4, 0x73));
  btn_reset = new Button(630, 38, 90, 34, "RESET", color(0xE1, 0x4B, 0x4B));

  reset_simulation();
  calculate_theoretical_stats();
}

void draw() {
  background(24, 26, 36);

  draw_environment();

  if (is_animating) {
    update_animation();
  }

  draw_trajectory();
  draw_cannon();
  draw_projectile();
  draw_ui();
}


// --- ฟังก์ชันการแสดงผลกราฟิก ---
void draw_environment() {
  stroke(80, 200, 120);
  strokeWeight(3);
  line(origin_x - 30, origin_y, width - 40, origin_y);

  fill(140, 150, 175);
  textSize(11);
  textAlign(CENTER, TOP);
  for (int m = 0; m < 550; m += 50) {
    float px = origin_x + m * scale_m;
    if (px < width - 40) {
      stroke(90, 100, 130);
      strokeWeight(1);
      line(px, origin_y, px, origin_y + 8);
      text(m + "m", px, origin_y + 12);
    }
  }
}

void draw_trajectory() {
  if (x_points.size() > 1) {
    noFill();
    stroke(0, 230, 255, 180);
    strokeWeight(2.5);
    beginShape();
    for (int i = 0; i < x_points.size(); i++) {
      float px = origin_x + (x_points.get(i) * scale_m);
      float py = origin_y - (y_points.get(i) * scale_m);
      vertex(px, py);
    }
    endShape();
  }
}

void draw_cannon() {
  pushMatrix();
  translate(origin_x, origin_y);
  rotate(-radians(launch_angle));
  fill(90, 95, 120);
  stroke(140, 150, 180);
  strokeWeight(1.5);
  rect(-10, -8, 45, 16, 4);
  popMatrix();

  fill(60, 65, 85);
  noStroke();
  arc(origin_x, origin_y, 35, 35, PI, TWO_PI);
}

void draw_projectile() {
  float px = origin_x + (current_x * scale_m);
  float py = origin_y - (current_y * scale_m);

  noStroke();
  fill(0, 0, 0, 70);
  ellipse(px, origin_y + 4, 16, 6);

  fill(255, 200, 40);
  stroke(255, 240, 150);
  strokeWeight(2);
  ellipse(px, py, 18, 18);

  if (is_animating) {
    float rad = radians(launch_angle);
    float vx = initial_velocity * cos(rad);
    float vy = initial_velocity * sin(rad) - (g * t);

    stroke(40, 240, 120);
    strokeWeight(2);
    line(px, py, px + vx * 0.8, py);

    stroke(255, 75, 130);
    line(px, py, px, py - vy * 0.8);
  }
}

void draw_ui() {
  slider_v.display();
  slider_angle.display();
  btn_start.display();
  btn_reset.display();

  float panel_x = width - 260;
  float panel_y = 35;
  fill(35, 38, 52, 230);
  stroke(60, 65, 90);
  strokeWeight(1.5);
  rect(panel_x, panel_y, 230, 200, 10);

  fill(0, 230, 255);
  textAlign(LEFT, TOP);
  textSize(14);
  text("PHYSICS TELEMETRY", panel_x + 18, panel_y + 15);

  fill(200, 205, 225);
  textSize(12);
  float line_h = 24;
  float y_off = panel_y + 42;

  text("Flight Time (T): " + nf(total_time, 0, 2) + " s", panel_x + 18, y_off);
  text("Max Height (H):  " + nf(max_height, 0, 2) + " m", panel_x + 18, y_off + line_h);
  text("Max Range (R):   " + nf(max_range, 0, 2) + " m", panel_x + 18, y_off + line_h * 2);

  stroke(60, 65, 90);
  line(panel_x + 15, y_off + line_h * 3, panel_x + 215, y_off + line_h * 3);

  fill(255, 215, 0);
  text("Realtime (t): " + nf(t, 0, 2) + " s", panel_x + 18, y_off + line_h * 3.5);
  text("Pos: (" + nf(current_x, 0, 1) + " m, " + nf(current_y, 0, 1) + " m)", panel_x + 18, y_off + line_h * 4.5);

  if (is_finished) {
    fill(40, 240, 120);
    textAlign(CENTER);
    textSize(15);
    text("TARGET REACHED", panel_x + 115, y_off + line_h * 5.7);
  }
}


// --- การจัดการ Event เมาส์ ---
void mousePressed() {
  if (btn_start.is_hover() && !is_animating) {
    reset_simulation();
    calculate_theoretical_stats();
    is_animating = true;
  } else if (btn_reset.is_hover()) {
    reset_simulation();
  }

  // ตรวจสอบการคลิกแยกสไลเดอร์
  if (slider_v.is_hover()) {
    slider_v.is_dragging = true;
    mouseDragged();
  } else if (slider_angle.is_hover()) {
    slider_angle.is_dragging = true;
    mouseDragged();
  }
}

void mouseDragged() {
  if (slider_v.is_dragging && !is_animating) {
    initial_velocity = slider_v.update();
    calculate_theoretical_stats();
  }
  if (slider_angle.is_dragging && !is_animating) {
    launch_angle = slider_angle.update();
    calculate_theoretical_stats();
  }
}

void mouseReleased() {
  slider_v.is_dragging = false;
  slider_angle.is_dragging = false;
}
