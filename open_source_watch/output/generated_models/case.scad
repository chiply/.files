// Open Source Watch Case Template
// Generated from YAML configuration

// Configuration variables
case_diameter = 40.0;
case_thickness = 12.0;
lug_width = 20.0;
lug_to_lug = 48.0;
movement_diameter = 28.5;
movement_thickness = 5.5;
crown_position = 3;
crown_diameter = 6.0;
tolerance = 0.1;

// Calculated values
movement_cavity_diameter = movement_diameter + tolerance;
crown_angle = crown_position * 30; // Convert to degrees

module watch_case() {
    difference() {
        union() {
            // Main case body
            cylinder(h=case_thickness, d=case_diameter, center=false, $fn=100);
            
            // Lugs
            lug_offset = lug_to_lug/2 - case_diameter/2;
            translate([0, lug_offset, 0])
                lug(lug_width);
            translate([0, -lug_offset, 0])
                lug(lug_width);
        }
        
        // Movement cavity
        translate([0, 0, 2.5])
            cylinder(h=movement_thickness + 0.5, 
                    d=movement_cavity_diameter, $fn=100);
        
        // Crown hole
        rotate([0, 0, crown_angle])
            translate([case_diameter/2, 0, case_thickness/2])
                rotate([0, 90, 0])
                    cylinder(h=8, d=crown_diameter + 0.2, $fn=50);
        
        // Crystal seat
        translate([0, 0, case_thickness - 1])
            cylinder(h=2, d=34.0 + 0.1, $fn=100);
    }
}

module lug(width) {
    lug_length = 8;
    lug_height = case_thickness;
    
    hull() {
        translate([0, 0, 0])
            cube([width, lug_length, lug_height], center=true);
        translate([0, lug_length/2 - 1, 0])
            cylinder(h=lug_height, d=width, center=true, $fn=50);
    }
    
    // Spring bar holes
    translate([width/2 - 1, 0, 0])
        rotate([0, 90, 0])
            cylinder(h=2, d=1.6, center=true, $fn=20);
    translate([-width/2 + 1, 0, 0])
        rotate([0, 90, 0])
            cylinder(h=2, d=1.6, center=true, $fn=20);
}

// Generate the case
watch_case();