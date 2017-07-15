import System.IO // for FileStream
import System // for BitConverter and Byte Type
import UnityEngine.UI
 
public class WavWriter (MonoBehaviour):

    private bufferSize  as int
    private numBuffers as int
    private outputRate as int = 44100
    public directoryField as Text
    public fileNameField as Text
    public metronomeInstrument as Instrument
    private headerSize as int = 44 //default for uncompressed wav
     
    public mixingInProgress as GameObject
    public progressBar as RectTransform
    public recOutput as bool
    private data as (single)
     
    private fileStream as FileStream
    private allDataSources as (single)
    private musicScore as MusicScore
    private width as single
     
    // Audio Source
    # private pausAudio as AudioSource
     
    def Awake():
        AudioSettings.outputSampleRate = outputRate
        data = array(single, 2 * outputRate)

        
     
    def Start():
        musicScore = Amvol.Amvol.musicScore
        AudioSettings.GetDSPBufferSize(bufferSize,numBuffers)
       
        // Make a reference to the attached audio source
        # pausAudio = gameObject.GetComponent(AudioSource)

    def Record():
        endPoint = 0
        for noteSection in musicScore.noteSections:
            if noteSection.transform.localPosition.x + noteSection.transform.GetComponent(RectTransform).sizeDelta.x > endPoint:
                endPoint = noteSection.transform.localPosition.x + noteSection.transform.GetComponent(RectTransform).sizeDelta.x
        width = endPoint * 8
        print('width: ' + width)

        if width > 0:
            print('start mixing')
            mixingInProgress.SetActive(true)
            metronomeInstrument.volume = 0
            musicScore.Stop()
            musicScore.Play()

            width += 32 //give it time to fade out
            Invoke("StopRecording", width * musicScore.beatTime)
            allDataSources = array(single, 0)
            recOutput = true
        else:
            print('nothing to record')

    def Update():
        if mixingInProgress.active:
            progressBar.localScale.x = musicScore.x / width


    def StopRecording():
        print('stop mixing')
        musicScore.Stop()
        metronomeInstrument.volume = 1
        recOutput = false
        ConvertAndWrite(allDataSources, Path.Combine(directoryField.text, fileNameField.text) + ".wav")      //audio data is interlaced
        print("writing to: " + Path.Combine(directoryField.text, fileNameField.text) + ".wav")
        mixingInProgress.SetActive(false)
     

     
    def OnAudioFilterRead(newData as (single), channels as int):
        if recOutput:
            allDataSources += newData
        # print(AudioSettings.dspTime)

     
    def ConvertAndWrite(dataSource as (single), fileName as string):
        intData as (int) = array(int, dataSource.Length)
    //converting in 2 steps as float[] to Int16[], //then Int16[] to (Byte)
       
        bytesData as (Byte) = array(Byte, (dataSource.Length*2) +2)
        print(bytesData.Length)
    //bytesData array is twice the size of
    //dataSource array because a float converted in Int16 is 2 bytes.
       
        rescaleFactor as single = 32767 //to convert float to Int16
       
        # i as int = 0
        # while i < dataSource.Length:
        #     intData[i] = dataSource[i]*rescaleFactor
        #     byteArr as (Byte) = array(Byte, 2)
        #     byteArr = BitConverter.GetBytes(intData[i])
        #     bytesData[i*2] = byteArr[0]
        #     bytesData[(i*2)+1] = byteArr[1]
        #     # byteArr.CopyTo(bytesData,i*2)

        #     i++
        for i in range(dataSource.Length):
            intData[i] = dataSource[i] * rescaleFactor
            byteArr as (Byte) = array(Byte, 2)
            byteArr = BitConverter.GetBytes(intData[i])
            byteArr.CopyTo(bytesData, i*2)

        StartWriting(fileName)
        WriteHeader(bytesData.Length)
        fileStream.Write(bytesData,0,bytesData.Length)
        fileStream.Close()
     

    def StartWriting(name as string):
        fileStream = FileStream(name, FileMode.Create)
        emptyByte as byte = byte()
       
        i as int = 0
        while i < headerSize:
            //preparing the header
            fileStream.WriteByte(emptyByte)
            i++


    def WriteHeader(dataSize as int):
        fileStream.Seek(0,SeekOrigin.Begin)
       
        riff as (Byte) = System.Text.Encoding.UTF8.GetBytes("RIFF")
        fileStream.Write(riff,0,4)
       
        chunkSize as (Byte) = BitConverter.GetBytes(fileStream.Length-8)
        fileStream.Write(chunkSize,0,4)
       
        wave as (Byte) = System.Text.Encoding.UTF8.GetBytes("WAVE")
        fileStream.Write(wave,0,4)
       
        fmt as (Byte) = System.Text.Encoding.UTF8.GetBytes("fmt ")
        fileStream.Write(fmt,0,4)
       
        subChunk1 as (Byte) = BitConverter.GetBytes(16)
        fileStream.Write(subChunk1,0,4)
       
        two as UInt16 = 2
        one as UInt16 = 1
     
        audioFormat as (Byte) = BitConverter.GetBytes(one)
        fileStream.Write(audioFormat,0,2)
       
        numChannels as (Byte) = BitConverter.GetBytes(two)
        fileStream.Write(numChannels,0,2)
       
        sampleRate as (Byte) = BitConverter.GetBytes(outputRate)
        fileStream.Write(sampleRate,0,4)
       
        byteRate as (Byte) = BitConverter.GetBytes(outputRate*4)
     // sampleRate * bytesPerSample*number of channels, here 44100*2*2
     
        fileStream.Write(byteRate,0,4)
       
        four as UInt16 = 4
        blockAlign as (Byte) = BitConverter.GetBytes(four)
        fileStream.Write(blockAlign,0,2)
       
        sixteen as UInt16 = 16
        bitsPerSample as (Byte) = BitConverter.GetBytes(sixteen)
        fileStream.Write(bitsPerSample,0,2)
       
        dataString as (Byte) = System.Text.Encoding.UTF8.GetBytes("data")
        fileStream.Write(dataString,0,4)
       
        subChunk2 as (Byte) = BitConverter.GetBytes(dataSize)
        fileStream.Write(subChunk2,0,4)
       
        