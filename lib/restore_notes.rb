require 'time'
require 'sqlite3'

class RestoreNotes

  def get_notes_from_db
    db = SQLite3::Database.new "NotesV6.storedata"
    rows = db.execute <<-SQL
SELECT zf.ZNAME
      ,zn.ZTITLE
      ,znb.ZHTMLSTRING
      ,zn.ZDATECREATED
      ,zn.ZDATEEDITED
FROM ZNOTE zn
JOIN ZFOLDER zf ON zn.ZFOLDER = zf.Z_PK
JOIN ZNOTEBODY znb ON znb.ZNOTE = zn.Z_PK
;
SQL
    return rows
  end


  def write_row_to_dir_and_folders(row)
    dirname = row[0].gsub(/[\:\/]/, '_')
    filename = row[1].gsub(/[\:\/]/, '_')
    datecreate = Time.at("1#{row[3]}".to_f).strftime("%Y.%m.%d %H:%M")
    dateedited = Time.at("1#{row[4]}".to_f).strftime("%Y.%m.%d %H:%M")

    Dir.mkdir(dirname) unless Dir.exist?(dirname)
    Dir.chdir(dirname) do |dir|
      File.open("#{datecreate} - #{dateedited} - #{filename}.html", "w") do |f|
        html = row[2]
        html.gsub!('<head></head>', '<head><meta charset="utf-8"></head>');
        html = "<!doctype html>" << html
        f << html
      end   
    end
  end

  def restore_notes
    rows = get_notes_from_db
    rows.each do |row|
      write_row_to_dir_and_folders(row)
    end
  end
end
