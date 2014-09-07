Project DaVinci
================

`DaVinci` is a small library, for OS X & iOS, that enables you to generate PNG Images with a message (of any length) embedded inside them. You can also do the other way around, by grabbing a previously created image, via `DaVinci` (or else it'll probably fail or return something unexpected), and retrieve the original string that was stored inside it.

> This project is named, of course, after Leonardo Da Vinci, mainly because of the messages he hid on some of his paintings, something that many Art historians believe (read more about this [here](http://www.telegraph.co.uk/culture/art/art-news/8197896/Mona-Lisa-painting-contains-hidden-code.html)).

## Example
With the following, well-known, Apple-y text:
> Here's to the crazy ones. The misfits. The rebels. The troublemakers. The round pegs in the square holes. The ones who see things differently. They're not fond of rules. And they have no respect for the status quo. You can quote them, disagree with them, glorify or vilify them. About the only thing you can't do is ignore them. Because they change things. They push the human race forward. And while some may see them as the crazy ones, we see genius. Because the people who are crazy enough to think they can change the world, are the ones who do.


`DaVinci` will generate the PNG image below:
![DaVinci Example](images/example.png)


## How Does It Work (encoding)

1. Starts by encoding the initial text to a Base64 string
2. Grabs every `char` of the newly created string and saves its ASCII code in a temporary `NSArray`
3. Creates the PNG data by storing, in each R/G/B of each pixel, all of the ASCII character codes that were previously saved, all in the right sequence:

   *Let's say I'm currently working with the following partial Base64 string "`yZS`"*

   | **Char**             | `y`     |   `Z`   |   `S`   |
   | ---------------------|:-------:|:-------:|:-------:|
   | **ASCII Value**      | 121     | 90      | 83      |
   |                      |  **R**  |  **G**  |  **B**  |

4. When all the text is already inside the PNG data, `DaVinci` will finish the image data by adding transparent pixels (Alpha = 0), if needed (just to fill the gaps)

## Usage
Generating a new PNG Image with a message embedded inside it:
```objective-c
//this will return a NSData object that contains all the PNG data which can be used to create a PNG file
NSData *pngData = [DaVinci generatePNGDataFromString:@"my secret message"];
[pngData writeToFile:@"your/path.png" atomatically:YES]; //create the PNG
```

Decoding an already created PNG Image via `DaVinci`:
```objective-c
//first you need to get the PNG image data
NSData *pngData = [NSData dataWithContentsOfFile:@"your/png/file/path.png"];

//now you just need to decode it to get the original text
NSString *originalString = [DaVinci retrieveStringFromPNGData:pngData];
```

## Requirements

OS X 10.7+ or iOS 5.0+.

## Features To Be Add (Possibly)

* Encode the original message encoded using `AES-256` and embed it inside the PNG
* Use another image (from the web or so) to store a message and `DaVinci` will be return a string of coordinates that can be used (later on via `DaVinci`) to retrieve the message.

## Author - Contact

[Pedro Vieira](http://pedrovieira.me/) ([@w1tch_](https://twitter.com/w1tch_))<br>
Send me an [email](mailto:pedrovieiradev@hotmail.com).

## License

`DaVinci` is available under the MIT license. See the LICENSE file for more info.