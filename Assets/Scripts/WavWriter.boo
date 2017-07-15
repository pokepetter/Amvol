import UnityEngine
import System
import System.IO

public class WavWriter(MonoBehaviour):
    // constants for the wave file header
    private static final HEADER_SIZE = 44
    private static final BITS_PER_SAMPLE as short = 16
    private static final SAMPLE_RATE = 44100
    // the number of audio channels in the output file
    private channels = 2
    // the audio stream instance
    private outputStream as MemoryStream
    private outputWriter as BinaryWriter

    public directoryField as Text
    public fileNameField as Text
    public metronomeInstrument as Instrument
     
    public mixingInProgress as GameObject
    public progressBar as RectTransform
    # public recOutput as bool
    private musicScore as MusicScore
    private width as single
    
    // should this object be rendering to the output stream?
    public recOutput = false
    public enum Status:
        UNKNOWN
        SUCCESS
        FAIL
        ASYNC
    
    # public class Result:
    #     public State as Status
    #     public Message as string
        
    #     public def constructor(newState as Status, newMessage as string):
    #         self.State = newState
    #         self.Message = newMessage


    public def constructor():
        self.Clear()

    // reset the renderer
    public def Clear():
        self.outputStream = MemoryStream()
        self.outputWriter = BinaryWriter(outputStream)
    
    public def Write(audioData as (single)):
        for i in range(0, audioData.Length):
        // Convert numeric audio data to bytes
            // write the short to the stream
            self.outputWriter.Write(((audioData[i] * (Int16.MaxValue cast single)) cast short))
    
    // write the incoming audio to the output string
    private def OnAudioFilterRead(data as (single), channels as int):
        if self.recOutput:
            // store the number of channels we are rendering
            self.channels = channels    
            // store the data stream
            self.Write(data)
        

    public def Save(filename as string):
        # result as Result = WavWriter.Result()
        if outputStream.Length > 0:
            // add a header to the file so we can send it to the SoundPlayer
            self.AddHeader()    
            // if a filename was passed in
            if filename.Length > 0:
                // Save to a file. Print a warning if overwriting a file.
                if File.Exists(filename):
                    Debug.LogWarning((('Overwriting ' + filename) + '...'))     
                // reset the stream pointer to the beginning of the stream
                outputStream.Position = 0       
                // write the stream to a file
                fs as FileStream = File.OpenWrite(filename) 
                self.outputStream.WriteTo(fs)   
                fs.Close()  
                // for debugging only
                Debug.Log((('Finished saving to ' + filename) + '.'))
                
            # result.State = Status.SUCCESS
        else:
            Debug.LogWarning('There is no audio data to save!')
            # result.State = Status.FAIL
            # result.Message = 'There is no audio data to save!'
        
        # return result

    
    private def AddHeader():
        // reset the output stream
        outputStream.Position = 0
        // calculate the number of samples in the data chunk
        numberOfSamples as long = (outputStream.Length / (BITS_PER_SAMPLE / 8))
        // create a new MemoryStream that will have both the audio data AND the header
        newOutputStream = MemoryStream()
        writer = BinaryWriter(newOutputStream)
        writer.Write(1179011410)
        // "RIFF" in ASCII
        // write the number of bytes in the entire file
        writer.Write((((HEADER_SIZE + (((numberOfSamples * BITS_PER_SAMPLE) * channels) / 8)) cast int) - 8))       
        writer.Write(1163280727)
        // "WAVE" in ASCII
        writer.Write(544501094)
        // "fmt " in ASCII
        writer.Write(16)        
        // write the format tag. 1 = PCM
        writer.Write((1 cast short))        
        // write the number of channels.
        writer.Write((channels cast short))     
        // write the sample rate. 44100 in this case. The number of audio samples per second
        writer.Write(SAMPLE_RATE)       
        writer.Write(((SAMPLE_RATE * channels) * (BITS_PER_SAMPLE / 8)))
        writer.Write(((channels * (BITS_PER_SAMPLE / 8)) cast short))       
        // 16 bits per sample
        writer.Write(BITS_PER_SAMPLE)       
        // "data" in ASCII. Start the data chunk.
        writer.Write(1635017060)        
        // write the number of bytes in the data portion
        writer.Write(((((numberOfSamples * BITS_PER_SAMPLE) * channels) / 8) cast int))     
        // copy over the actual audio data
        self.outputStream.WriteTo(newOutputStream)      
        // move the reference to the new stream
        self.outputStream = newOutputStream


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
            outputStream = MemoryStream()
            outputWriter = BinaryWriter(outputStream)
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
        # ConvertAndWrite(allDataSources, Path.Combine(directoryField.text, fileNameField.text) + ".wav")      //audio data is interlaced
        Save(Path.Combine(directoryField.text, fileNameField.text) + ".wav")
        print("writing to: " + Path.Combine(directoryField.text, fileNameField.text) + ".wav")
        mixingInProgress.SetActive(false)

    def Start():
        musicScore = Amvol.Amvol.musicScore
        # AudioSettings.GetDSPBufferSize(bufferSize,numBuffers)