#!/usr/bin/env ruby

require "csv"

def add_student(csvfile)
#
# Add the new student into the table by insert it at the end of the table.
#

	response = nil
	puts "\nEnter info in this format: first, last name, email, section, major1, major2, minor1, minor2 (note: first, last, email, section, major1 are required)."
	print "\n>"

	response = gets.chomp
	myArray = response.split(',')

	new_csv = [] #create an array to hold the new CSV data

	#verify the first 4 fields (first,last,email,section) are required. If not valid just print error
	
  if myArray[0]==nil || myArray[1]==nil || myArray[2]==nil || myArray[3]==nil || myArray[4] == nil
    puts "input is not valid"
	else
	  old_csv = CSV.read(csvfile, headers:true) #read the whole file
		old_csv.each do |oldrow| #loop thru each row
		  new_csv << oldrow #copy the rows from old table into new table
		end

		new_student = "#{myArray[0]},#{myArray[1]},#{myArray[2]},#{myArray[3]},#{myArray[4]},#{myArray[5]},#{myArray[6]},#{myArray[7]}"
		new_csv << new_student

  end

	puts "\nNew table with the new entry at the end"
	new_csv.each do |row| #print the new table should have the last entry is the new row
			puts row
	end
end

def delete_student(csvfile)
#
# Delete a student from the table. The code will search for the entry in the table 
# using the email address because email suppose to be unique
#
	response = nil
	puts "\nEnter email address of student want to be deleted."
	print "\n>"

	response = gets.chomp
	new_csv = [] #to hold the new csv table

	old_csv = CSV.read(csvfile, headers:true)
	old_csv.each do |oldrow| 
		if oldrow['email'] != response		#gothru the row of the old table, if the row does not match copy to the new table
			new_csv << oldrow								#if it matches just keep that row so it will not be copied to the new table.
		end
	end

	new_csv.each do |row|
			puts row
	end
end

def update_student(csvfile)
#
# update one student record by enter the complete new info. The code will search on the current
# table by using email or first and last name. When it found it will be replaced with the new row
#
	response = nil
	puts "\n Enter the complete the new record that will replace the existing record."
  puts "\n The code will use first_nam & last_name or email address to search for existing record"
	print "\n>"

	response = gets.chomp
	myArray = response.split(',')
	old_csv = CSV.read(csvfile, headers:true)

	new_csv = [] #create an array to hold the new CSV data
	
  if myArray[0]==nil || myArray[1]==nil || myArray[2]==nil || myArray[3]==nil || myArray[4]== nil
    puts "input is not valid"
	else
		old_csv.each do |oldrow|		#loop thru the row and search row has email or first/last name matched.
			if oldrow['email'] == myArray[2] || (oldrow['first_name'] == myArray[0] && oldrow['last_name']==myArray[1]) 
				puts "\nFound the record: #{oldrow}\n"
				updated_student = "#{myArray[0]},#{myArray[1]},#{myArray[2]},#{myArray[3]},#{myArray[4]},#{myArray[5]},#{myArray[6]},#{myArray[7]}"
				new_csv << updated_student
			else
				new_csv << oldrow
			end
		end
	end
				
	new_csv.each do |row|	#print the new table with the new info
			puts row
	end
end

def create_groups(csvfile)
#
#	form the groups, each group will have 6 students.
# the users can specify the contraints:
#   a. all students in the group needed to have the same section number
#   b. the user can specify a specific major1 for all the students in the group or it does not care.
# The users can tell the code to write the list of group to a given file beside display on the screen.
#
	response = nil
	section = nil
	yesNo_input = nil
	outfile = nil
	group_major = nil

	puts "\n Put the students into 6 per group with the following conditions"
	puts "\n Enter section number"
	print "\n> "
  section = gets.chomp
	puts "\n Should students have the same major? enter major or hit ret for no"
	print "\n> "
	group_major = gets.chomp
	puts "\n Do you want the list of group write to the file, enter the filename or hit ret for no"
	print "\n> "
	outfile = gets.chomp

	details = []

	CSV.foreach(csvfile) do |row|
		details << row
	end

	results = nil

	if group_major != ""
		puts "group with major #{group_major}"
		results = details.select do |hash|
			hash[3] == section  && hash[4] == group_major
		end
	else
		results = details.select do |hash|
			hash[3] == section  
		end
	end

	$group_num=1
	$group_max=5
	$group_count=0

	if outfile != ""
		puts "writing to #{outfile}"
		file = File.new(outfile,"w")
		results.each do |hash|
			if $group_count == 0
				puts "\n**** Group #{$group_num} ****"
				file.puts "\n**** Group #{$group_num} ****"
			end
			puts hash.to_s
			file.puts "#{hash.to_s}\n"
			if $group_count < $group_max
				$group_count += 1
			else
				$group_count = 0
				$group_num += 1
			end
		end
		file.close
	else
		results.each do |hash|
        if $group_count == 0
          puts "**** Group #{$group_num} ****"
        end
        puts hash.to_s
        if $group_count < $group_max
          $group_count += 1
        else
          $group_count = 0
          $group_num += 1
        end
      end
	end
end

#
# This is the main logic of the code, the user enter the input file for the students.
# The code will ask the user to enter the actions and based on the input it will call
# different functions to perform it.
#

response = nil

puts "\nType file name to process:"
print "\n>"
filename= gets.chomp

# The code will do basic validate the data to make sure the input file meet the requirement
# if not it will exit.

puts "\nThe data file is #{filename}\n"
File.open(filename) do |file|
  file.each_line do |line|
		myArray = line.split(',')
    if myArray[0] == " " || myArray[1] == " " || myArray[2] == "" || myArray[3] == " " || myArray[4] == " "
			abort("file does not confirm to the requirement at #{line}")
    end
  end
  puts "#{filename} file is read in OK \n"
end

#main actions to edit the data or create groups
response = nil
until response == 'q'
	puts "\nType 'e' to edit data\n"
	puts "Type 'c' to create the groups\n"
	print "\n>"

#sub menu to allow user to add,delete,update data or create/list/group.
#create/list/group is one action where the user can have option to write to the specify file				
	response = gets.chomp
	case
		when response == 'e'
			puts "Type 'a' to add the new student"
			puts "Type 'd' to delete the new student"
			puts "Type 'u' to update the new student"
			print '> '
			response = gets.chomp
			case 
				when response == 'a'
					add_student(filename)
				when response == 'd'
					delete_student(filename)
				when response == 'u'
					update_student(filename)
				else
					puts "invalid input"
			end
		when response =='c'
			create_groups(filename)
		when response == 'q'
			puts "done.existing"
		else
				puts "invalid input"
	end
end
