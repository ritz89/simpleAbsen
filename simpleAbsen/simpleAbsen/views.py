"""
Routes and views for the flask application.
"""

from datetime import datetime
from flask import render_template, request, jsonify
from simpleAbsen import app
import mysql.connector

mydb = mysql.connector.connect(
  host="localhost",
  port="3306",
  user="root",
  passwd="root",
  database="absen"
)
cursor = mydb.cursor()

@app.route('/')
@app.route('/home')
def home():
    """Renders the home page."""
    
    cursor.execute("select * from kelas")
    mk = cursor.fetchall()
    return render_template(
        'index.html',
        title='Home Page',
        year=datetime.now().year,
        mk=mk,
    )

@app.route('/absensi',methods=['GET', 'POST'])
def mulaiAbsen():
    pertemuan = request.form.get("pert")
    kelas = request.form.get("kelas") 
    kd_mk = request.form["kd_mk"]
    return render_template(
        'absensi.html',
        title='Home Page',
        year=datetime.now().year,
        pertemuan = pertemuan,
        kelas = kelas,
        kd_mk = kd_mk,
    )

def extractKelas(kd_mk, kelas):
    cursor.execute("""
        SELECT mahasiswas.NIM, mahasiswas.Nama, coalesce(kehadiran.is_attending,0) as hadir, kehadiran.dtm_attendance, kehadiran.pertemuan, kelas.kode_kelas, kelas.kode_mk FROM mahasiswas
        JOIN kelas_mahasiswa on mahasiswas.id = kelas_mahasiswa.Mahasiswas_id
        JOIN kelas on kelas_mahasiswa.kelas_id = kelas.id
        left join kehadiran on kehadiran.kelas_mahasiswa_Mahasiswas_id = kelas_mahasiswa.Mahasiswas_id and kehadiran.kelas_mahasiswa_kelas_id= kelas_mahasiswa.kelas_id
        where kelas.kode_kelas='"""+ kelas+"""' 
        and kelas.kode_mk = '"""+ kd_mk+"""'
        """)
    mhs = cursor.fetchall()
    return mhs

def absenGenerated(pertemuan, kode_kelas, kode_mk):
    query = "select count(*) from kehadiran WHERE kelas_mahasiswa_kelas_id =(select id from kelas WHERE kode_mk = '"+kode_mk+"' and kode_kelas='"+kode_kelas+"') and pertemuan = "+pertemuan
    cursor.execute(query)
    res = cursor.fetchone()[0]
    return res

@app.route("/getabsen")
def getAbsen():
    pertemuan = request.args["pertemuan"]
    kelas = request.args["kelas"]
    kd_mk = request.args["kd_mk"]
    mhs = extractKelas(kd_mk, kelas)
    if(not absenGenerated(pertemuan, kelas, kd_mk)):
       insertAbsen(mhs, pertemuan)
    absensi = getAbsensi(pertemuan, kd_mk, kelas)
    jmlMhs=len(absensi)
    return jsonify(absensi)
    
def getAbsensi(pertemuan, kd_mk, kelas):
    query = "select mahasiswas.NIM, mahasiswas.Nama, is_attending, dtm_attendance, pertemuan, kelas.kode_kelas, kelas.kode_mk from kehadiran JOIN mahasiswas on mahasiswas.id = kehadiran.kelas_mahasiswa_Mahasiswas_id join kelas on kelas.id = kehadiran.kelas_mahasiswa_kelas_id WHERE pertemuan = "+pertemuan+" and kode_mk = '"+kd_mk+"' and kode_kelas = '"+kelas+"'"
    cursor.execute(query)
    return cursor.fetchall()

@app.route("/doAbsen")
def doAbsen():
    nim = request.args["NIM"]
    kd_mk = request.args["kd_mk"]
    kd_kls = request.args["kd_kls"]
    pert = request.args["pertemuan"]
    if(cekAbsensi(nim, kd_mk, kd_kls,pert)>0):
        return "mahasiswa sudah absen"
    return updateAbsen(nim,kd_mk,kd_kls, pert,"masuk")

def insertAbsen(mhs, pertemuan):
    try:
        for m in mhs:
            query = "insert into kehadiran (active, dtm_attendance ,is_attending, permission, pertemuan, kelas_mahasiswa_Mahasiswas_id, kelas_mahasiswa_kelas_id ) VALUES(1,NULL,0,'-',"+pertemuan+",(select id from mahasiswas where NIM='"+m[0]+"'),(select id from kelas WHERE kode_mk = '"+m[6]+"' and kode_kelas='"+m[5]+"'))"
            cursor.execute(query)
        mydb.commit()
    except mysql.connector.Error as err:
        mydb.rollback()
        return ("Something went wrong: {}".format(err))

    return "success"


def cekAbsensi(NIM, kode_mk, kode_kelas, pertemuan):
    query = "select is_attending from kehadiran where kelas_mahasiswa_Mahasiswas_id = (select id from mahasiswas where NIM='"+NIM+"""') and kelas_mahasiswa_kelas_id = (select id from kelas WHERE kode_mk = '"""+kode_mk+"' and kode_kelas='"+kode_kelas+"') and pertemuan = "+pertemuan
    cursor.execute(query)
    res = cursor.fetchone()[0]
    return res

def updateAbsen(NIM, kode_mk, kode_kelas, pertemuan, absen):
    abs = ""
    if(absen==1):
        abs = NIM
    try:
        query = "update kehadiran set is_attending = 1, permission = '"+absen+"', dtm_attendance = NOW() WHERE pertemuan = "+pertemuan+" and kelas_mahasiswa_kelas_id = (select id from kelas WHERE kode_mk = '"""+kode_mk+"' and kode_kelas='"+kode_kelas+"') and kelas_mahasiswa_Mahasiswas_id = (select id from mahasiswas where NIM='"+NIM+"')"
        cursor.execute(query)
        mydb.commit()
    except mysql.connector.Error as err:
        mydb.rollback()
        return ("Something went wrong: {}".format(err))
    return "success"

@app.route('/contact')
def contact():
    """Renders the contact page."""
    return render_template(
        'contact.html',
        title='Contact',
        year=datetime.now().year,
        message='Your contact page.'
    )

@app.route('/about')
def about():
    """Renders the about page."""
  
    return render_template(
        'about.html',
        title='About',
        year=datetime.now().year,
        message=mhs
    )
