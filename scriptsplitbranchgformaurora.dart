function onFormSubmit(e) {
  // Cek apakah event object dan values ada
  if (!e || !e.values) {
    Logger.log("Event object atau values tidak ditemukan.");
    return;
  }

  // Log data respons yang diterima
  Logger.log("Form Data: " + e.values);

  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const mainSheet = ss.getSheetByName("Form Response 1"); // Nama sheet utama dari Form Responses
  const responses = e.values; // Data respons yang diterima dari formulir

  Logger.log("Responses: " + responses); // Menampilkan data respons untuk debug

  const branchColumnIndex = 3; // Kolom Cabang Pengerjaan (misal, kolom C)
  const branchName = responses[branchColumnIndex - 1]; // Ambil nama cabang dari respons

  // Jika nama cabang kosong, hentikan eksekusi
  if (!branchName) return;

  // Cek apakah spreadsheet dengan nama cabang sudah ada
  let branchSpreadsheet = DriveApp.getFilesByName(branchName);
  let branchSheet;
  if (branchSpreadsheet.hasNext()) {
    // Jika spreadsheet sudah ada, ambil spreadsheet tersebut
    branchSpreadsheet = branchSpreadsheet.next();
    branchSheet = SpreadsheetApp.open(branchSpreadsheet).getSheets()[0]; // Ambil sheet pertama
  } else {
    // Buat spreadsheet baru jika belum ada
    const newSpreadsheet = SpreadsheetApp.create(branchName); // Membuat spreadsheet baru dengan nama cabang
    branchSheet = newSpreadsheet.getSheets()[0]; // Ambil sheet pertama dari spreadsheet baru
    
    // Salin header dari sheet utama "Form Responses 1" ke sheet baru
    const headers = mainSheet.getRange(1, 1, 1, mainSheet.getLastColumn()).getValues()[0];
    branchSheet.appendRow(headers); // Menambahkan header ke sheet baru
    Logger.log("New Spreadsheet created: " + newSpreadsheet.getUrl());
  }

  // Menambahkan data respons ke sheet baru atau yang sudah ada
  branchSheet.appendRow(responses); // Menambahkan respons yang disubmit ke sheet cabang yang sesuai

  Logger.log("Data added to spreadsheet: " + branchSheet.getParent().getUrl());

  // Menambahkan URL spreadsheet baru atau yang sudah ada ke sheet "Labels"
  const labelSheet = ss.getSheetByName("Labels"); // Nama sheet untuk label
  if (labelSheet) {
    labelSheet.appendRow([branchName, responses.join(", "), branchSheet.getParent().getUrl()]);
  }
}
