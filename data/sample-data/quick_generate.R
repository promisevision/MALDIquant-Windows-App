# Quick Test Data Generator
# Run this in R to quickly create a test file

library(MALDIquant)

cat("Creating quick test spectrum...\n")

# Generate mass and intensity data
mass <- seq(1000, 5000, by = 0.5)
intensity <- rnorm(length(mass), mean = 100, sd = 15)

# Add 5 clear peaks
peaks <- c(1500, 2000, 2500, 3000, 3500)
for (p in peaks) {
  idx <- which.min(abs(mass - p))
  intensity[(idx-20):(idx+20)] <- intensity[(idx-20):(idx+20)] + 400
}

# Save
df <- data.frame(mass = mass, intensity = intensity)
write.table(df, "quick_test.txt", sep = "\t", row.names = FALSE, quote = FALSE)

cat("✓ Created: quick_test.txt\n")
cat("  Location:", normalizePath("quick_test.txt"), "\n")
cat("  Size:", round(file.size("quick_test.txt") / 1024, 2), "KB\n")
cat("\nYou can now import this file in the MALDIquant application!\n")
