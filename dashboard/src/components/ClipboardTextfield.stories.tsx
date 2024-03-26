import { ComponentStory, ComponentMeta } from '@storybook/react';
import ClipboardTextfield from './ClipboardTextfield';

export default {
  title: 'library/ClipboardTextfield',
  component: ClipboardTextfield,
} as ComponentMeta<typeof ClipboardTextfield>;

const Template: ComponentStory<typeof ClipboardTextfield> = (args) => (
  <ClipboardTextfield {...args} />
);

export const Default = Template.bind({});
Default.args = {
  text: 'Hello World',
  className: 'text-h3 text-gray-300',
};

export const Small = Template.bind({});
Small.args = {
  text: 'Hello World',
  className: 'text-regular text-gray-300',
};

const mine = 'hi';
