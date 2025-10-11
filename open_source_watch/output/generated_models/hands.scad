// Open Source Watch Hands Template

// Configuration
hand_style = "sword";
hour_length = 12.0;
minute_length = 14.0;
second_length = 15.0;
include_second = true;

module watch_hands() {
    // Hour hand
    translate([30, 0, 0]) hour_hand();
    
    // Minute hand  
    translate([0, 0, 0]) minute_hand();
    
    // Second hand
    translate([-30, 0, 0]) second_hand();
}

module hour_hand() {
    hand_thickness = 0.8;
    hand_width = 2.5;
    
    linear_extrude(height=hand_thickness) {
        polygon(points=[
            [0, -hand_width/2],
            [hour_length * 0.7, -hand_width/3],
            [hour_length, 0],
            [hour_length * 0.7, hand_width/3],
            [0, hand_width/2],
            [-2, 0]
        ]);
    }
    
    // Center hole
    translate([0, 0, -0.1])
        cylinder(h=hand_thickness + 0.2, d=1.5, $fn=20);
}

module minute_hand() {
    hand_thickness = 0.6;
    hand_width = 2.0;
    
    linear_extrude(height=hand_thickness) {
        polygon(points=[
            [0, -hand_width/2],
            [minute_length * 0.8, -hand_width/3],
            [minute_length, 0],
            [minute_length * 0.8, hand_width/3],
            [0, hand_width/2],
            [-3, 0]
        ]);
    }
    
    // Center hole
    translate([0, 0, -0.1])
        cylinder(h=hand_thickness + 0.2, d=1.2, $fn=20);
}

module second_hand() {
    hand_thickness = 0.4;
    hand_width = 0.8;
    
    // Main hand body
    linear_extrude(height=hand_thickness) {
        polygon(points=[
            [0, -hand_width/2],
            [second_length * 0.9, -hand_width/2],
            [second_length, 0],
            [second_length * 0.9, hand_width/2],
            [0, hand_width/2],
            [-4, 0]
        ]);
    }
    
    // Center hole
    translate([0, 0, -0.1])
        cylinder(h=hand_thickness + 0.2, d=0.8, $fn=15);
        
    // Balance weight
    translate([-6, 0, 0])
        cylinder(h=hand_thickness, d=3, $fn=20);
}

// Generate all hands
watch_hands();