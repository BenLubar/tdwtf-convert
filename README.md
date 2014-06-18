1. For each `.sql` file, use SSMS &rarr; Tasks &rarr; Export Data... &rarr; *select your database* &rarr; *filename should be the same as the `.sql` but with `.csv`*, Destination: `Flat File Destination`, `Unicode` &rarr; `Write a query to specify the data to transfer` &rarr; *paste in the contents of the `.sql` file*
2. Open the `.csv` files in your favorite text editor and re-save them as UTF-8 with *no* BOM.
3. Copy the `.csv` files to `/var/www/discourse/script/import_scripts/` on your Docker instance.
4. Edit the `specific to TDWTF` section if you are converting a different Community Server forum. The data is '*community server section id*' => *discourse category id* for any categories you have already made on Discourse.
5. Copy `communityserver.rb` to `/var/www/discourse/script/import_scripts/`
6. Run the following command in your Docker instance:  
   `(cd /var/www/discourse/script/import_scripts/ && RAILS_ENV=production sudo -E -u discourse bundle exec ruby communityserver.rb)`
7. You have now migrated your Community Server forum to Discourse.
