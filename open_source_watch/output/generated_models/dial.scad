// Open Source Watch Dial Template

// Configuration
dial_diameter = 32.0;
dial_thickness = 0.8;
marker_style = "indices";
logo_text = "OPEN SOURCE";
brand_text = "WATCH PROJECT";

module watch_dial() {
    difference() {
        union() {
            // Main dial disc
            cylinder(h=dial_thickness, d=dial_diameter, $fn=100);
            
            // Hour markers
            for(i = [0:11]) {
                rotate([0, 0, i * 30])
                    translate([dial_diameter/2 - 2, 0, dial_thickness])
                        hour_index();
            }
        }
        
        // Center hole for hands
        cylinder(h=dial_thickness + 2, d=3, center=true, $fn=30);
        
        // Movement mounting feet holes
        for(angle = [0, 120, 240]) {
            rotate([0, 0, angle])
                translate([28.5/2 - 2, 0, -1])
                    cylinder(h=dial_thickness + 2, d=1, $fn=20);
        }
    }
    
    // Text elements
    translate([0, 6, dial_thickness])
        linear_extrude(height=0.2)
            text(logo_text, size=2, halign="center", valign="center");
            
    translate([0, -6, dial_thickness])
        linear_extrude(height=0.2)
            text(brand_text, size=1.5, halign="center", valign="center");
}

module hour_index() {
    cube([3, 0.8, 1.5], center=true);
}

module numeral(number) {
    linear_extrude(height=0.5)
        text(str(number), size=2.5, halign="center", valign="center");
}

// Generate the dial
watch_dial();