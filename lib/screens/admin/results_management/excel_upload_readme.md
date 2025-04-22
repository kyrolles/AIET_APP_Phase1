# Student Grades Excel Upload Format

This document explains the required format for uploading student grades using Excel files.

## Excel File Format

The Excel file must follow this format:

| Column | Content | Format | Example |
|--------|---------|--------|---------|
| A | Student ID | Text | 2023001 |
| B | Student Name | Text | John Smith |
| C | Course Code | Text | MATH301 |
| D | 5th-week | Decimal (0-8) | 6.5 |
| E | 10th-week | Decimal (0-12) | 10.0 |
| F | Classwork | Decimal (0-10) | 8.5 |
| G | Lab Exam | Decimal (0-10) | 8.0 |
| H | Final Exam | Decimal (0-60) | 45.5 |
| I | Total Points | Decimal (0-100) | 78.5 |

## Points Distribution

The total points (100) are distributed as follows:
- 5th-week exam: 8 points maximum
- 10th-week exam: 12 points maximum
- Classwork: 10 points maximum
- Lab exam: 10 points maximum
- Final exam: 60 points maximum

## Grade Calculation

Grades are automatically calculated based on the total points:
- A+: 93-100
- A: 90-92.9
- A-: 87-89.9
- B+: 83-86.9
- B: 80-82.9
- B-: 77-79.9
- C+: 73-76.9
- C: 70-72.9
- C-: 67-69.9
- D+: 63-66.9
- D: 60-62.9
- F: Below 60

## Important Notes

1. The first row should contain headers (will be skipped during processing)
2. Student ID must exactly match the ID stored in the user record
3. Course Code must match the code in the department subjects collection
4. If the Total Points column is left empty, it will be calculated as the sum of all assessment components
5. Empty cells will be interpreted as 0.0 for numeric scores

## Example

| Student ID | Student Name | Course Code | 5th-week (8) | 10th-week (12) | Classwork (10) | Lab Exam (10) | Final Exam (60) | Total Points |
|------------|--------------|------------|--------------|----------------|----------------|---------------|-----------------|--------------|
| 2023001 | John Smith | MATH101 | 6.5 | 10.0 | 8.5 | 7.5 | 45.0 | 77.5 |
| 2023001 | John Smith | PHYS101 | 7.0 | 9.5 | 9.0 | 8.0 | 50.0 | 83.5 |
| 2023002 | Jane Doe | CHEM101 | 7.5 | 11.0 | 9.0 | 8.5 | 55.0 | 91.0 |
| 2023003 | Alex Brown | CS101 | 8.0 | 10.5 | 8.0 | 9.5 | 52.0 | 88.0 |

## Access Control

Only users with Admin or IT roles can upload Excel files and modify student grades.

## Process Flow

1. Select the semester for which grades should be assigned
2. Upload the Excel file with grades
3. The system will:
   - Validate and process the file
   - Match student IDs with Firestore user IDs
   - Update the grades for matched students
   - Log the upload activity for audit purposes
4. A success message will be shown with the number of student records processed

If any errors occur during processing, an error message will be displayed. 