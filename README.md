# z Command Tool

เครื่องมือสำหรับเก็บและเรียกใช้คำสั่ง shell แบบง่ายๆ พร้อม tab completion สำหรับ bash และ zsh

## คุณสมบัติ

- ✅ เก็บคำสั่ง shell ไว้ใช้งานซ้ำ
- ✅ รันคำสั่งด้วยหมายเลข
- ✅ ค้นหาคำสั่งที่เก็บไว้
- ✅ แสดงสถิติการใช้งาน
- ✅ Tab completion สำหรับ bash และ zsh
- ✅ สีสันสวยงาม (rainbow colors)
- ✅ รองรับ cd command พร้อม path expansion

## การติดตั้ง

### วิธีที่ 1: ใช้ Install Script (แนะนำ)

```bash
# รัน install script
chmod +x install.sh
./install.sh
```

### วิธีที่ 2: ติดตั้งด้วยตนเอง

1. **คัดลอกไฟล์ z.sh:**
```bash
cp z.sh ~/.local/bin/z
chmod +x ~/.local/bin/z
```

2. **เพิ่ม PATH ใน shell configuration:**
```bash
# สำหรับ zsh (เพิ่มใน ~/.zshrc)
export PATH="$HOME/.local/bin:$PATH"

# สำหรับ bash (เพิ่มใน ~/.bashrc)
export PATH="$HOME/.local/bin:$PATH"
```

3. **ติดตั้ง Tab Completion:**

**สำหรับ zsh:**
```bash
# สร้าง directory
mkdir -p ~/.zsh/completions

# คัดลอก completion file
cp _z_completion ~/.zsh/completions/_z

# เพิ่มใน ~/.zshrc
echo "fpath=(\$HOME/.zsh/completions \$fpath)" >> ~/.zshrc
echo "autoload -U compinit" >> ~/.zshrc
echo "compinit -d \$HOME/.zcompdump" >> ~/.zshrc
```

**สำหรับ bash:**
```bash
# สร้าง directory
mkdir -p ~/.bash_completion.d

# คัดลอก completion file
cp z_bash_completion.sh ~/.bash_completion.d/z

# เพิ่มใน ~/.bashrc
echo "if [ -f \$HOME/.bash_completion.d/z ]; then" >> ~/.bashrc
echo "    . \$HOME/.bash_completion.d/z" >> ~/.bashrc
echo "fi" >> ~/.bashrc
```

## การใช้งาน

### คำสั่งพื้นฐาน

```bash
# เพิ่มคำสั่งใหม่
z add "ls -la"

# ดูรายการคำสั่งทั้งหมด
z list
# หรือ
z ls

# รันคำสั่งด้วยหมายเลข
z 1

# ลบคำสั่ง
z delete 1

# ค้นหาคำสั่ง
z search "ls"

# ดูสถิติ
z stats

# ล้างคำสั่งทั้งหมด
z clear

# ดูความช่วยเหลือ
z help
```

### ตัวอย่างการใช้งาน

```bash
# เพิ่มคำสั่งที่ใช้บ่อย
z add "cd ~/projects"
z add "git status"
z add "docker ps"
z add "ps aux | grep"

# ดูรายการ
z list
# Output:
#   1: cd ~/projects
#   2: git status
#   3: docker ps
#   4: ps aux | grep

# รันคำสั่ง
z 1  # จะ cd ไปที่ ~/projects
z 2  # จะรัน git status
```

### Tab Completion

- กด `Tab` หลังจากพิมพ์ `z` เพื่อดูคำสั่งที่ใช้ได้
- กด `Tab` หลังจาก `z add` เพื่อดูคำสั่งที่แนะนำ
- กด `Tab` หลังจาก `z delete` เพื่อดูหมายเลขคำสั่งที่มีอยู่

## ไฟล์ที่เกี่ยวข้อง

- `z.sh` - ไฟล์หลักของ z command tool
- `install.sh` - Script สำหรับติดตั้งอัตโนมัติ
- `_z_completion` - Tab completion สำหรับ zsh
- `z_bash_completion.sh` - Tab completion สำหรับ bash
- `~/.z_commands` - ไฟล์เก็บคำสั่ง (สร้างอัตโนมัติ)

## การลบออก

```bash
# ลบไฟล์ executable
rm ~/.local/bin/z

# ลบ completion files
rm ~/.zsh/completions/_z  # สำหรับ zsh
rm ~/.bash_completion.d/z # สำหรับ bash

# ลบข้อมูลคำสั่ง (ถ้าต้องการ)
rm ~/.z_commands

# ลบ configuration จาก shell files (ต้องทำด้วยตนเอง)
```

## การแก้ไขปัญหา

### z command ไม่ทำงาน
```bash
# ตรวจสอบ PATH
echo $PATH | grep .local/bin

# ตรวจสอบไฟล์
ls -la ~/.local/bin/z
```

### Tab completion ไม่ทำงาน
```bash
# สำหรับ zsh
source ~/.zshrc

# สำหรับ bash
source ~/.bashrc
```

### ไฟล์ไม่พบ
```bash
# สร้าง directory ที่จำเป็น
mkdir -p ~/.local/bin
mkdir -p ~/.zsh/completions
mkdir -p ~/.bash_completion.d
```